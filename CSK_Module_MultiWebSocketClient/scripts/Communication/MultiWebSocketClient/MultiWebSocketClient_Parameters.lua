---@diagnostic disable: redundant-parameter, undefined-global

--***************************************************************
-- Inside of this script, you will find the relevant parameters
-- for this module and its default values
--***************************************************************

local functions = {}

local function getParameters()
  local multiWebSocketClientParameters = {}

  multiWebSocketClientParameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  multiWebSocketClientParameters.processingFile = 'CSK_MultiWebSocketClient_Processing' -- which file to use for processing (will be started in own thread)
  multiWebSocketClientParameters.showLog = false -- Show log in UI
  multiWebSocketClientParameters.forwardEvents = {} -- List of events to register to and forward content via websocket
  multiWebSocketClientParameters.clientActivated = false -- Set if HTTP client should be active
  multiWebSocketClientParameters.url = '' -- Set if HTTP client should be active
  multiWebSocketClientParameters.timeout = 5000 -- Timeout to wait for connection
  multiWebSocketClientParameters.headerKey = '' -- Key of header field to establish the WebSocket connection
  multiWebSocketClientParameters.headerValue = '' -- Value of header field to establish the WebSocket connection
  multiWebSocketClientParameters.messageFormat = 'TEXT' -- Format of WebSocket message

  return multiWebSocketClientParameters
end
functions.getParameters = getParameters

return functions