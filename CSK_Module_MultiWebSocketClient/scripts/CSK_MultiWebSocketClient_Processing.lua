---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

-- If App property "LuaLoadAllEngineAPI" is FALSE, use this to load and check for required APIs
-- This can improve performance of garbage collection
-- local availableAPIs = require('Mainfolder/Subfolder/helper/checkAPIs') -- check for available APIs
-----------------------------------------------------------
local nameOfModule = 'CSK_MultiWebSocketClient'
--Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')

local scriptParams = Script.getStartArgument() -- Get parameters from model

local multiWebSocketClientInstanceNumber = scriptParams:get('multiWebSocketClientInstanceNumber') -- number of this instance
local multiWebSocketClientInstanceNumberString = tostring(multiWebSocketClientInstanceNumber) -- number of this instance as string
--local viewerId = scriptParams:get('viewerId')
--local viewer = View.create(viewerId) --> if needed
-- e.g. local object = MachineLearning.DeepNeuralNetwork.create() -- Use any AppEngine CROWN needed

-- Event to notify result of processing
Script.serveEvent("CSK_MultiWebSocketClient.OnNewResult" .. multiWebSocketClientInstanceNumberString, "MultiWebSocketClient_OnNewResult" .. multiWebSocketClientInstanceNumberString, 'auto') -- Edit this accordingly
-- Event to forward content from this thread to Controller to show e.g. on UI
Script.serveEvent("CSK_MultiWebSocketClient.OnNewValueToForward".. multiWebSocketClientInstanceNumberString, "MultiWebSocketClient_OnNewValueToForward" .. multiWebSocketClientInstanceNumberString, 'string, auto')
-- Event to forward update of e.g. parameter update to keep data in sync between threads
Script.serveEvent("CSK_MultiWebSocketClient.OnNewValueUpdate" .. multiWebSocketClientInstanceNumberString, "MultiWebSocketClient_OnNewValueUpdate" .. multiWebSocketClientInstanceNumberString, 'int, string, auto, int:?')

local processingParams = {}
processingParams.registeredEvent = scriptParams:get('registeredEvent')
processingParams.activeInUI = false
--processingParams.showImage = scriptParams:get('showImage') -- if needed

-- optionally
--[[
local function setAllProcessingParameters(paramContainer)
  processingParams.paramA = paramContainer:get('paramA')
  processingParams.paramB = paramContainer:get('paramB')
  processingParams.selectedObject = paramContainer:get('selectedObject')

  -- ...

  processingParams.internalObjects = helperFuncs.convertContainer2Table(paramContainer:get('internalObjects'))

end
setAllProcessingParameters(scriptParams)
]]

local function handleOnNewProcessing(data)

  _G.logger:fine(nameOfModule .. ": Check data on instance No." .. multiWebSocketClientInstanceNumberString)

  -- Insert processing part
  -- E.g.
  --[[

  local result = someProcessingFunctions(data)

  Script.notifyEvent("MultiWebSocketClient_OnNewValueUpdate" .. multiWebSocketClientInstanceNumberString, multiWebSocketClientInstanceNumber, 'valueName', result, processingParams.selectedObject)

  if processingParams.showImage and processingParams.activeInUI then
    viewer:addImage(image)
    viewer:present("LIVE")
  end
  ]]

  --_G.logger:fine(nameOfModule .. ": Processing on MultiWebSocketClient" .. multiWebSocketClientInstanceNumberString .. " was = " .. tostring(result))
  Script.notifyEvent('MultiWebSocketClient_OnNewResult'.. multiWebSocketClientInstanceNumberString, data)

  --Script.notifyEvent("MultiWebSocketClient_OnNewValueToForward" .. multiWebSocketClientInstanceNumberString, 'MultiWebSocketClient_CustomEventName', 'content')

  --Script.releaseObject(data)

end
Script.serveFunction("CSK_MultiWebSocketClient.processInstance"..multiWebSocketClientInstanceNumberString, handleOnNewProcessing, 'auto', 'auto:?') -- Edit this according to this function

--- Function to deregister from event
local function deregisterFromEvent()
  _G.logger:fine(nameOfModule .. ": Deregister instance " .. multiWebSocketClientInstanceNumberString .. " from event.")
  Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
  processingParams.registeredEvent = ''
end

--- Function to handle updates of processing parameters from Controller
---@param multiWebSocketClientNo int Number of instance to update
---@param parameter string Parameter to update
---@param value auto Value of parameter to update
---@param internalObjectNo int? Number of object
local function handleOnNewProcessingParameter(multiWebSocketClientNo, parameter, value, internalObjectNo)

  if multiWebSocketClientNo == multiWebSocketClientInstanceNumber then -- set parameter only in selected script
    _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiWebSocketClientInstanceNo." .. tostring(multiWebSocketClientNo) .. " to value = " .. tostring(value))

    --[[
    if internalObjectNo then
      _G.logger:fine(nameOfModule .. ": Update parameter '" .. parameter .. "' of multiWebSocketClientInstanceNo." .. tostring(multiWebSocketClientNo) .. " of internalObject No." .. tostring(internalObjectNo) .. " to value = " .. tostring(value))
      processingParams.internalObjects[internalObjectNo][parameter] = value

    elseif parameter == 'FullSetup' then
      if type(value) == 'userdata' then
        if Object.getType(value) == 'Container' then
            setAllProcessingParameters(value)
        end
      end

    -- further checks
    --elseif parameter == 'chancelEditors' then
    end

    else
    ]]

    if parameter == 'registeredEvent' then
      _G.logger:fine(nameOfModule .. ": Register instance " .. multiWebSocketClientInstanceNumberString .. " on event " .. value)
      if processingParams.registeredEvent ~= '' then
        Script.deregister(processingParams.registeredEvent, handleOnNewProcessing)
      end
      processingParams.registeredEvent = value
      Script.register(value, handleOnNewProcessing)

    -- elseif parameter == 'someSpecificParameter' then
    --   --Setting something special...
    --   processingParams.specificVariable = value
    --   --Do some more specific...

    elseif parameter == 'deregisterFromEvent' then
      deregisterFromEvent()

    else
      processingParams[parameter] = value
      --if  parameter == 'showImage' and value == false then
      --  viewer:clear()
      --  viewer:present()
      --end
    end
  elseif parameter == 'activeInUI' then
    processingParams[parameter] = false
  end
end
Script.register("CSK_MultiWebSocketClient.OnNewProcessingParameter", handleOnNewProcessingParameter)
