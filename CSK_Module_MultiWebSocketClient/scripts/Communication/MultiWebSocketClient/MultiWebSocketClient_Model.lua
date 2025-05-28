---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_MultiWebSocketClient'

-- Create kind of "class"
local multiWebSocketClient = {}
multiWebSocketClient.__index = multiWebSocketClient

multiWebSocketClient.styleForUI = 'None' -- Optional parameter to set UI style
multiWebSocketClient.version = Engine.getCurrentAppVersion() -- Version of module

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

--- Function to react on UI style change
local function handleOnStyleChanged(theme)
  multiWebSocketClient.styleForUI = theme
  Script.notifyEvent("MultiWebSocketClient_OnNewStatusCSKStyle", multiWebSocketClient.styleForUI)
end
Script.register('CSK_PersistentData.OnNewStatusCSKStyle', handleOnStyleChanged)

--- Function to create new instance
---@param multiWebSocketClientInstanceNo int Number of instance
---@return table[] self Instance of multiWebSocketClient
function multiWebSocketClient.create(multiWebSocketClientInstanceNo)

  local self = {}
  setmetatable(self, multiWebSocketClient)

  self.multiWebSocketClientInstanceNo = multiWebSocketClientInstanceNo -- Number of this instance
  self.multiWebSocketClientInstanceNoString = tostring(self.multiWebSocketClientInstanceNo) -- Number of this instance as string
  self.helperFuncs = require('Communication/MultiWebSocketClient/helper/funcs') -- Load helper functions

  -- Create parameters etc. for this module instance
  self.activeInUI = false -- Check if this instance is currently active in UI

  -- Check if CSK_PersistentData module can be used if wanted
  self.persistentModuleAvailable = CSK_PersistentData ~= nil or false

  -- Check if CSK_UserManagement module can be used if wanted
  self.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

  -- Default values for persistent data
  -- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
  self.parametersName = 'CSK_MultiWebSocketClient_Parameter' .. self.multiWebSocketClientInstanceNoString -- name of parameter dataset to be used for this module
  self.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

  self.isConnected = false -- Current connection status
  self.dataToTransmit = '' -- Preset data to transmit

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters = self.helperFuncs.defaultParameters.getParameters() -- Load default parameters

  -- Parameters to give to the processing script
  self.multiWebSocketClientProcessingParams = Container.create()
  self.multiWebSocketClientProcessingParams:add('multiWebSocketClientInstanceNumber', multiWebSocketClientInstanceNo, "INT")
  self.multiWebSocketClientProcessingParams:add('showLog', self.parameters.showLog, "BOOL")
  self.multiWebSocketClientProcessingParams:add('clientActivated', self.parameters.clientActivated, "BOOL")
  self.multiWebSocketClientProcessingParams:add('url', self.parameters.url, "STRING")
  self.multiWebSocketClientProcessingParams:add('timeout', self.parameters.timeout, "INT")
  self.multiWebSocketClientProcessingParams:add('headerKey', self.parameters.headerKey, "STRING")
  self.multiWebSocketClientProcessingParams:add('headerValue', self.parameters.headerValue, "STRING")
  self.multiWebSocketClientProcessingParams:add('messageFormat', self.parameters.messageFormat, "STRING")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiWebSocketClientProcessingParams)

  return self
end

return multiWebSocketClient

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************