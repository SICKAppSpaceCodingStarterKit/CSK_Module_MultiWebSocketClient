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

  -- Optionally check if specific API was loaded via
  --[[
  if _G.availableAPIs.specific then
  -- ... doSomething ...
  end
  ]]

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

  --self.object = Image.create() -- Use any AppEngine CROWN
  --self.counter = 1 -- Short docu of variable
  --self.varA = 'value' -- Short docu of variable

  -- Parameters to be saved permanently if wanted
  self.parameters = {}
  self.parameters.flowConfigPriority = CSK_FlowConfig ~= nil or false -- Status if FlowConfig should have priority for FlowConfig relevant configurations
  self.parameters.registeredEvent = '' -- If thread internal function should react on external event, define it here, e.g. 'CSK_OtherModule.OnNewInput'
  self.parameters.processingFile = 'CSK_MultiWebSocketClient_Processing' -- which file to use for processing (will be started in own thread)
  --self.parameters.showImage = true -- Short docu of variable
  --self.parameters.paramA = 'paramA' -- Short docu of variable
  --self.parameters.paramB = 123 -- Short docu of variable

  self.parameters.internalObject = {} -- optionally
  --self.parameters.selectedObject = 1 -- Which object is currently selected
  --[[
    for i = 1, 10 do
    local obj = {}

    obj.objectName = 'Object' .. tostring(i) -- name of the object
    obj.active = false  -- is this object active
    -- ...

    table.insert(self.parameters.internalObject, obj)
  end

  local internalObjectContainer = self.helperFuncs.convertTable2Container(self.parameters.internalObject)
  ]]

  -- Parameters to give to the processing script
  self.multiWebSocketClientProcessingParams = Container.create()
  self.multiWebSocketClientProcessingParams:add('multiWebSocketClientInstanceNumber', multiWebSocketClientInstanceNo, "INT")
  self.multiWebSocketClientProcessingParams:add('registeredEvent', self.parameters.registeredEvent, "STRING")
  --self.multiWebSocketClientProcessingParams:add('showImage', self.parameters.showImage, "BOOL")
  --self.multiWebSocketClientProcessingParams:add('viewerId', 'multiWebSocketClientViewer' .. self.multiWebSocketClientInstanceNoString, "STRING")

  --self.multiWebSocketClientProcessingParams:add('internalObjects', internalObjectContainer, "OBJECT") -- optionally
  --self.multiWebSocketClientProcessingParams:add('selectedObject', self.parameters.selectedObject, "INT")

  -- Handle processing
  Script.startScript(self.parameters.processingFile, self.multiWebSocketClientProcessingParams)

  return self
end

--[[
--- Some internal code docu for local used function to do something
function multiWebSocketClient:doSomething()
  self.object:doSomething()
end

--- Some internal code docu for local used function to do something else
function multiWebSocketClient:doSomethingElse()
  self:doSomething() --> access internal function
end
]]

return multiWebSocketClient

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************