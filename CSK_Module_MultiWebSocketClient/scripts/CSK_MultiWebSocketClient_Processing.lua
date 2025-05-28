---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
local availableAPIs = require('Communication/MultiWebSocketClient/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiWebSocketClient'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiWebSocketClientInstanceNumber = scriptParams:get('multiWebSocketClientInstanceNumber') -- number of this instance
local multiWebSocketClientInstanceNumberString = tostring(multiWebSocketClientInstanceNumber) -- number of this instance as string

-- Event to notify received WebSocket client data
Script.serveEvent("CSK_MultiWebSocketClient.OnNewData" .. multiWebSocketClientInstanceNumberString, "MultiWebSocketClient_OnNewData" .. multiWebSocketClientInstanceNumberString, 'binary, string')
-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiWebSocketClient.OnNewValueToForward".. multiWebSocketClientInstanceNumberString, "MultiWebSocketClient_OnNewValueToForward" .. multiWebSocketClientInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiWebSocketClient.OnNewValueUpdate" .. multiWebSocketClientInstanceNumberString, "MultiWebSocketClient_OnNewValueUpdate" .. multiWebSocketClientInstanceNumberString, 'int, string, auto, int:?')

local websocketClientHandle = WebsocketClient.create()

local processingParams = {}
processingParams.activeInUI = false
processingParams.clientActivated = scriptParams:get('clientActivated')
processingParams.showLog = scriptParams:get('showLog')
processingParams.url = scriptParams:get('url')
processingParams.timeout = scriptParams:get('timeout')
processingParams.headerKey = scriptParams:get('headerKey')
processingParams.headerValue = scriptParams:get('headerValue')
processingParams.messageFormat = scriptParams:get('messageFormat')

processingParams.currentConnectionStatus = false

processingParams.forwardEvents = {}

local log = {} -- Log of WebSocket communication

local queue = Script.Queue.create() -- Queue to stop processing if increasing too much
queue:setPriority("MID")
queue:setMaxQueueSize(1)

--- Function to notify latest log messages, e.g. to show on UI
local function sendLog()
  if #log == 100 then
    table.remove(log, 100)
  end
  local tempLog = ''
  for i=1, #log do
    tempLog = tempLog .. tostring(log[i]) .. '\n'
  end
  if processingParams.activeInUI then
    Script.notifyEvent("MultiWebSocketClient_OnNewValueToForward" .. multiWebSocketClientInstanceNumberString, 'MultiWebSocketClient_OnNewLog', tostring(tempLog))
  end
end

local function handleOnConnected(httpResponse)
  local content = WebsocketClient.Response.getContent(httpResponse) -- binary
  local headerKeys = httpResponse:getHeaderKeys() --STRING *
  local headerValues = {}
  for key, value in pairs(headerKeys) do
    headerValues[value] = {}
    local success, internalValues = httpResponse:getHeaderValues(value)
    if success then
      for _, subValue in pairs(internalValues) do
        table.insert(headerValues[value], subValue)
      end
    end
  end

  local statusCode = httpResponse:getStatusCode()
  if processingParams.showLog then
    table.insert(log, 1, DateTime.getTime() .. ' - Connection opened. Status code = ' .. tostring(statusCode))
    sendLog()
  end

  _G.logger:info(nameOfModule .. ': Connection opened!')
  processingParams.currentConnectionStatus = true
  Script.notifyEvent("MultiWebSocketClient_OnNewValueToForward" .. multiWebSocketClientInstanceNumberString, 'MultiWebSocketClient_OnNewStatusCurrentlyConnected', processingParams.currentConnectionStatus)
  Script.notifyEvent("MultiWebSocketClient_OnNewValueUpdate" .. multiWebSocketClientInstanceNumberString, multiWebSocketClientInstanceNumber, 'currentConnectionStatus', processingParams.currentConnectionStatus)
end

local function handleOnDisconnected(serverCloseCode, serverCloseReason, clientCloseCode, clientCloseReason, error)

  processingParams.currentConnectionStatus = false

  if processingParams.showLog then
    table.insert(log, 1, DateTime.getTime() .. ' - Connection closed!')
    sendLog()
  end

  _G.logger:info(nameOfModule .. ': Connection closed!')
  _G.logger:info(nameOfModule .. ': CloseCode = "' .. tostring(serverCloseCode) .. '", CloseReason = "' .. tostring(serverCloseReason) .. '", ClientCloseCode = "' .. tostring(clientCloseCode) .. '", ClientCloseReason = "' .. tostring(clientCloseReason) .. '"')

  if error then
    local category = error:getCategory()
    local errMessage = error:getMessage()
    _G.logger:warning(nameOfModule .. ': Error category = "' .. tostring(category) .. '", Error message = "' .. tostring(errMessage))
  end

  Script.notifyEvent("MultiWebSocketClient_OnNewValueToForward" .. multiWebSocketClientInstanceNumberString, 'MultiWebSocketClient_OnNewStatusCurrentlyConnected', processingParams.currentConnectionStatus)
  Script.notifyEvent("MultiWebSocketClient_OnNewValueUpdate" .. multiWebSocketClientInstanceNumberString, multiWebSocketClientInstanceNumber, 'currentConnectionStatus', processingParams.currentConnectionStatus)
end

local function handleTransmitData(data)

  _G.logger:fine(nameOfModule .. ": Try to send data on instance No. " .. multiWebSocketClientInstanceNumberString)

  local success = false

  if processingParams.currentConnectionStatus ~= nil then
    success = websocketClientHandle:transmit(data, processingParams.messageFormat)
    if processingParams.showLog then
      if processingParams.messageFormat == 'TEXT' then
        table.insert(log, 1, DateTime.getTime() .. ' - SENT = ' .. tostring(data) .. ' to URL: ' .. tostring(processingParams.url))
      else
        table.insert(log, 1, DateTime.getTime() .. ' - SENT = BINARY DATA to URL: ' .. tostring(processingParams.url))
      end

      sendLog()
    end

    if success then
      _G.logger:fine(nameOfModule .. ": Send: " .. tostring(data))
    else
      _G.logger:warning(nameOfModule .. ": WebSocket transmit failed")
    end
  else
    _G.logger:warning(nameOfModule .. ": No WebSocket connection.")
  end
  return success

end
Script.serveFunction("CSK_MultiWebSocketClient.transmitData"..multiWebSocketClientInstanceNumberString, handleTransmitData, 'binary:1', 'bool:1')

--- Function only used to forward the content from events to the served function.
--- This is only needed, as deregistering from the event would internally release the served function and would make it uncallable from external.
---@param data binary Data to transmit
local function tempHandleTransmitData(data)
  handleTransmitData(data)
end

--- Function to handle incoming WebSocket data
---@param data binary The received data packet
---@param format string Message format
local function handleOnReceive(data, format)

  -- Forward data to other modules
  Script.notifyEvent("MultiWebSocketClient_OnNewData" .. multiWebSocketClientInstanceNumberString, data, format)

  if processingParams.showLog then
    if format == 'TEXT' then
      _G.logger:fine(nameOfModule .. ": Received data on instance No. " .. multiWebSocketClientInstanceNumberString .. " = " .. data)
      table.insert(log, 1, DateTime.getTime() .. ' - RECV = ' .. tostring(data))
    else
      _G.logger:fine(nameOfModule .. ": Received binary data on instance No. " .. multiWebSocketClientInstanceNumberString)
      table.insert(log, 1, DateTime.getTime() .. ' - RECV = ...BINARY DATA...')
    end
    sendLog()
  end
end

--- Function to handle updates of processing parameters from Controller
---@param multiWebSocketClientNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
local function handleOnNewProcessingParameter(multiWebSocketClientNo, parameter, value)

  if parameter == 'showLog' then
    processingParams[parameter] = value

  elseif multiWebSocketClientNo == multiWebSocketClientInstanceNumber then -- set parameter only in selected script
    if value then
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiWebSocketClientInstanceNo." .. tostring(multiWebSocketClientNo) .. " to value = " .. tostring(value))
    else
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiWebSocketClientInstanceNo." .. tostring(multiWebSocketClientNo))
    end

    if parameter == 'connect' then
      processingParams.connectionStatus = true
      local success, error, httpResponse = websocketClientHandle:connect(processingParams.timeout)
      if not success then
        _G.logger:warning(nameOfModule .. ": Did not connect!")
      end

    elseif parameter == 'disconnect' then
      processingParams.connectionStatus = false
      local success = websocketClientHandle:disconnect()

    elseif parameter == 'transmit' then
      handleTransmitData(value)

    elseif parameter == 'addEvent' then
      if processingParams.forwardEvents[value] then
        Script.deregister(processingParams.forwardEvents[value], tempHandleTransmitData)
      end
      processingParams.forwardEvents[value] = value

      local suc = Script.register(value, tempHandleTransmitData)
      _G.logger:fine(nameOfModule .. ": Added event to forward content = " .. value .. " on instance No. " .. multiWebSocketClientInstanceNumberString)
      _G.logger:fine(nameOfModule .. ": Success to register to event = " .. tostring(suc) .. " on instance No. " .. multiWebSocketClientInstanceNumberString)

    elseif parameter == 'removeEvent' then
      processingParams.forwardEvents[value] = nil
      local suc = Script.deregister(value, tempHandleTransmitData)
      _G.logger:fine(nameOfModule .. ": Deleted event = " .. tostring(value) .. " on instance No. " .. multiWebSocketClientInstanceNumberString)
      _G.logger:fine(nameOfModule .. ": Success to deregister of event = " .. tostring(suc) .. " on instance No. " .. multiWebSocketClientInstanceNumberString)

    elseif parameter == 'url' then
      processingParams[parameter] = value
      websocketClientHandle:setURL(value)

    else
      processingParams[parameter] = value
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiWebSocketClient.OnNewProcessingParameter", handleOnNewProcessingParameter)

websocketClientHandle:register('OnReceive', handleOnReceive)
queue:setFunction(handleOnReceive)
websocketClientHandle:register('OnConnected', handleOnConnected)
websocketClientHandle:register('OnDisconnected', handleOnDisconnected)
