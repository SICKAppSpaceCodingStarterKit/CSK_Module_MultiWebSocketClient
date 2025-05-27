---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the MultiWebSocketClient_Model and _Instances
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_MultiWebSocketClient'

local funcs = {}

-- Timer to update UI via events after page was loaded
local tmrMultiWebSocketClient = Timer.create()
tmrMultiWebSocketClient:setExpirationTime(300)
tmrMultiWebSocketClient:setPeriodic(false)

local multiWebSocketClient_Model -- Reference to model handle
local multiWebSocketClient_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('Communication/MultiWebSocketClient/helper/funcs')

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiWebSocketClient.processInstanceNUM", emptyFunction)

Script.serveEvent("CSK_MultiWebSocketClient.OnNewResultNUM", "MultiWebSocketClient_OnNewResultNUM")
Script.serveEvent("CSK_MultiWebSocketClient.OnNewValueToForwardNUM", "MultiWebSocketClient_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiWebSocketClient.OnNewValueUpdateNUM", "MultiWebSocketClient_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
-- Script.serveEvent("CSK_MultiWebSocketClient.OnNewEvent", "MultiWebSocketClient_OnNewEvent")
Script.serveEvent('CSK_MultiWebSocketClient.OnNewResult', 'MultiWebSocketClient_OnNewResult')

Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusModuleVersion', 'MultiWebSocketClient_OnNewStatusModuleVersion')
Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusCSKStyle', 'MultiWebSocketClient_OnNewStatusCSKStyle')
Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusModuleIsActive', 'MultiWebSocketClient_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusRegisteredEvent', 'MultiWebSocketClient_OnNewStatusRegisteredEvent')

Script.serveEvent("CSK_MultiWebSocketClient.OnNewStatusLoadParameterOnReboot", "MultiWebSocketClient_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_MultiWebSocketClient.OnPersistentDataModuleAvailable", "MultiWebSocketClient_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_MultiWebSocketClient.OnNewParameterName", "MultiWebSocketClient_OnNewParameterName")

Script.serveEvent("CSK_MultiWebSocketClient.OnNewInstanceList", "MultiWebSocketClient_OnNewInstanceList")
Script.serveEvent("CSK_MultiWebSocketClient.OnNewProcessingParameter", "MultiWebSocketClient_OnNewProcessingParameter")
Script.serveEvent("CSK_MultiWebSocketClient.OnNewSelectedInstance", "MultiWebSocketClient_OnNewSelectedInstance")
Script.serveEvent("CSK_MultiWebSocketClient.OnDataLoadedOnReboot", "MultiWebSocketClient_OnDataLoadedOnReboot")

Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusFlowConfigPriority', 'MultiWebSocketClient_OnNewStatusFlowConfigPriority')
Script.serveEvent("CSK_MultiWebSocketClient.OnUserLevelOperatorActive", "MultiWebSocketClient_OnUserLevelOperatorActive")
Script.serveEvent("CSK_MultiWebSocketClient.OnUserLevelMaintenanceActive", "MultiWebSocketClient_OnUserLevelMaintenanceActive")
Script.serveEvent("CSK_MultiWebSocketClient.OnUserLevelServiceActive", "MultiWebSocketClient_OnUserLevelServiceActive")
Script.serveEvent("CSK_MultiWebSocketClient.OnUserLevelAdminActive", "MultiWebSocketClient_OnUserLevelAdminActive")

-- ...

-- ************************ UI Events End **********************************

--[[
--- Some internal code docu for local used function
local function functionName()
  -- Do something

end
]]

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("MultiWebSocketClient_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("MultiWebSocketClient_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("MultiWebSocketClient_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("MultiWebSocketClient_OnUserLevelAdminActive", status)
end
-- ***********************************************

--- Function to forward data updates from instance threads to Controller part of module
---@param eventname string Eventname to use to forward value
---@param value auto Value to forward
local function handleOnNewValueToForward(eventname, value)
  Script.notifyEvent(eventname, value)
end

--- Optionally: Only use if needed for extra internal objects -  see also Model
--- Function to sync paramters between instance threads and Controller part of module
---@param instance int Instance new value is coming from
---@param parameter string Name of the paramter to update/sync
---@param value auto Value to update
---@param selectedObject int? Optionally if internal parameter should be used for internal objects
local function handleOnNewValueUpdate(instance, parameter, value, selectedObject)
    multiWebSocketClient_Instances[instance].parameters.internalObject[selectedObject][parameter] = value
end

--- Function to get access to the multiWebSocketClient_Model object
---@param handle handle Handle of multiWebSocketClient_Model object
local function setMultiWebSocketClient_Model_Handle(handle)
  multiWebSocketClient_Model = handle
  Script.releaseObject(handle)
end
funcs.setMultiWebSocketClient_Model_Handle = setMultiWebSocketClient_Model_Handle

--- Function to get access to the multiWebSocketClient_Instances object
---@param handle handle Handle of multiWebSocketClient_Instances object
local function setMultiWebSocketClient_Instances_Handle(handle)
  multiWebSocketClient_Instances = handle
  if multiWebSocketClient_Instances[selectedInstance].userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)

  for i = 1, #multiWebSocketClient_Instances do
    Script.register("CSK_MultiWebSocketClient.OnNewValueToForward" .. tostring(i) , handleOnNewValueToForward)
  end

  for i = 1, #multiWebSocketClient_Instances do
    Script.register("CSK_MultiWebSocketClient.OnNewValueUpdate" .. tostring(i) , handleOnNewValueUpdate)
  end

end
funcs.setMultiWebSocketClient_Instances_Handle = setMultiWebSocketClient_Instances_Handle

--- Function to update user levels
local function updateUserLevel()
  if multiWebSocketClient_Instances[selectedInstance].userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("MultiWebSocketClient_OnUserLevelAdminActive", true)
    Script.notifyEvent("MultiWebSocketClient_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("MultiWebSocketClient_OnUserLevelServiceActive", true)
    Script.notifyEvent("MultiWebSocketClient_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrMultiWebSocketClient()
  -- Script.notifyEvent("MultiWebSocketClient_OnNewEvent", false)

  Script.notifyEvent("MultiWebSocketClient_OnNewStatusModuleVersion", 'v' .. multiWebSocketClient_Model.version)
  Script.notifyEvent("MultiWebSocketClient_OnNewStatusCSKStyle", multiWebSocketClient_Model.styleForUI)
  Script.notifyEvent("MultiWebSocketClient_OnNewStatusModuleIsActive", _G.availableAPIs.default and _G.availableAPIs.specific)

  if _G.availableAPIs.default and _G.availableAPIs.specific then

    updateUserLevel()

    Script.notifyEvent('MultiWebSocketClient_OnNewSelectedInstance', selectedInstance)
    Script.notifyEvent("MultiWebSocketClient_OnNewInstanceList", helperFuncs.createStringListBySize(#multiWebSocketClient_Instances))

    Script.notifyEvent("MultiWebSocketClient_OnNewStatusRegisteredEvent", multiWebSocketClient_Instances[selectedInstance].parameters.registeredEvent)

    Script.notifyEvent("MultiWebSocketClient_OnNewStatusFlowConfigPriority", multiWebSocketClient_Instances[selectedInstance].parameters.flowConfigPriority)
    Script.notifyEvent("MultiWebSocketClient_OnNewStatusLoadParameterOnReboot", multiWebSocketClient_Instances[selectedInstance].parameterLoadOnReboot)
    Script.notifyEvent("MultiWebSocketClient_OnPersistentDataModuleAvailable", multiWebSocketClient_Instances[selectedInstance].persistentModuleAvailable)
    Script.notifyEvent("MultiWebSocketClient_OnNewParameterName", multiWebSocketClient_Instances[selectedInstance].parametersName)
  end
  -- ...
end
Timer.register(tmrMultiWebSocketClient, "OnExpired", handleOnExpiredTmrMultiWebSocketClient)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    updateUserLevel() -- try to hide user specific content asap
  end
  tmrMultiWebSocketClient:start()
  return ''
end
Script.serveFunction("CSK_MultiWebSocketClient.pageCalled", pageCalled)

local function setSelectedInstance(instance)
  if #multiWebSocketClient_Instances >= instance then
    selectedInstance = instance
    _G.logger:fine(nameOfModule .. ": New selected instance = " .. tostring(selectedInstance))
    multiWebSocketClient_Instances[selectedInstance].activeInUI = true
    Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)
    tmrMultiWebSocketClient:start()
  else
    _G.logger:warning(nameOfModule .. ": Selected instance does not exist.")
  end
end
Script.serveFunction("CSK_MultiWebSocketClient.setSelectedInstance", setSelectedInstance)

local function getInstancesAmount ()
  if multiSerialCom_Instances then
    return #multiWebSocketClient_Instances
  else
    return 0
  end
end
Script.serveFunction("CSK_MultiWebSocketClient.getInstancesAmount", getInstancesAmount)

local function addInstance()
  _G.logger:fine(nameOfModule .. ": Add instance")
  table.insert(multiWebSocketClient_Instances, multiWebSocketClient_Model.create(#multiWebSocketClient_Instances+1))
  Script.deregister("CSK_MultiWebSocketClient.OnNewValueToForward" .. tostring(#multiWebSocketClient_Instances) , handleOnNewValueToForward)
  Script.register("CSK_MultiWebSocketClient.OnNewValueToForward" .. tostring(#multiWebSocketClient_Instances) , handleOnNewValueToForward)
  handleOnExpiredTmrMultiWebSocketClient()
end
Script.serveFunction('CSK_MultiWebSocketClient.addInstance', addInstance)

local function resetInstances()
  _G.logger:info(nameOfModule .. ": Reset instances.")
  setSelectedInstance(1)
  local totalAmount = #multiWebSocketClient_Instances
  while totalAmount > 1 do
    Script.releaseObject(multiWebSocketClient_Instances[totalAmount])
    multiWebSocketClient_Instances[totalAmount] =  nil
    totalAmount = totalAmount - 1
  end
  handleOnExpiredTmrMultiWebSocketClient()
end
Script.serveFunction('CSK_MultiWebSocketClient.resetInstances', resetInstances)

local function setRegisterEvent(event)
  multiWebSocketClient_Instances[selectedInstance].parameters.registeredEvent = event
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'registeredEvent', event)
end
Script.serveFunction("CSK_MultiWebSocketClient.setRegisterEvent", setRegisterEvent)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'activeInUI', true)

  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'registeredEvent', multiWebSocketClient_Instances[selectedInstance].parameters.registeredEvent)

  --Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'value', multiWebSocketClient_Instances[selectedInstance].parameters.value)

  -- optionally for internal objects...
  --[[
  -- Send config to instances
  local params = helperFuncs.convertTable2Container(multiWebSocketClient_Instances[selectedInstance].parameters.internalObject)
  Container.add(data, 'internalObject', params, 'OBJECT')
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'FullSetup', data)
  ]]

end

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_MultiWebSocketClient.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  for i = 1, #multiWebSocketClient_Instances do
    multiWebSocketClient_Instances[i].parameters.registeredEvent = ''
    Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', i, 'deregisterFromEvent', '')
    Script.notifyEvent('MultiWebSocketClient_OnNewStatusRegisteredEvent', '')
  end
end
Script.serveFunction('CSK_MultiWebSocketClient.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function getParameters(instanceNo)
  if instanceNo <= #multiWebSocketClient_Instances then
    return helperFuncs.json.encode(multiWebSocketClient_Instances[instanceNo].parameters)
  else
    return ''
  end
end
Script.serveFunction('CSK_MultiWebSocketClient.getParameters', getParameters)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name = " .. tostring(name))
  multiWebSocketClient_Instances[selectedInstance].parametersName = name
end
Script.serveFunction("CSK_MultiWebSocketClient.setParameterName", setParameterName)

local function sendParameters(noDataSave)
  if multiWebSocketClient_Instances[selectedInstance].persistentModuleAvailable then
    CSK_PersistentData.addParameter(helperFuncs.convertTable2Container(multiWebSocketClient_Instances[selectedInstance].parameters), multiWebSocketClient_Instances[selectedInstance].parametersName)

    -- Check if CSK_PersistentData version is >= 3.0.0
    if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiWebSocketClient_Instances[selectedInstance].parametersName, multiWebSocketClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance), #multiWebSocketClient_Instances)
    else
      CSK_PersistentData.setModuleParameterName(nameOfModule, multiWebSocketClient_Instances[selectedInstance].parametersName, multiWebSocketClient_Instances[selectedInstance].parameterLoadOnReboot, tostring(selectedInstance))
    end
    _G.logger:fine(nameOfModule .. ": Send MultiWebSocketClient parameters with name '" .. multiWebSocketClient_Instances[selectedInstance].parametersName .. "' to CSK_PersistentData module.")
    if not noDataSave then
      CSK_PersistentData.saveData()
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_MultiWebSocketClient.sendParameters", sendParameters)

local function loadParameters()
  if multiWebSocketClient_Instances[selectedInstance].persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(multiWebSocketClient_Instances[selectedInstance].parametersName)
    if data then
      _G.logger:info(nameOfModule .. ": Loaded parameters for multiWebSocketClientObject " .. tostring(selectedInstance) .. " from CSK_PersistentData module.")
      multiWebSocketClient_Instances[selectedInstance].parameters = helperFuncs.convertContainer2Table(data)

      -- If something needs to be configured/activated with new loaded data
      --updateProcessingParameters()

      tmrMultiWebSocketClient:start()
      return true
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
      tmrMultiWebSocketClient:start()
      return false
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
    tmrMultiWebSocketClient:start()
    return false
  end
end
Script.serveFunction("CSK_MultiWebSocketClient.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  multiWebSocketClient_Instances[selectedInstance].parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
  Script.notifyEvent("MultiWebSocketClient_OnNewStatusLoadParameterOnReboot", status)
end
Script.serveFunction("CSK_MultiWebSocketClient.setLoadOnReboot", setLoadOnReboot)

local function setFlowConfigPriority(status)
  multiWebSocketClient_Instances[selectedInstance].parameters.flowConfigPriority = status
  _G.logger:fine(nameOfModule .. ": Set new status of FlowConfig priority: " .. tostring(status))
  Script.notifyEvent("MultiWebSocketClient_OnNewStatusFlowConfigPriority", multiWebSocketClient_Instances[selectedInstance].parameters.flowConfigPriority)
end
Script.serveFunction('CSK_MultiWebSocketClient.setFlowConfigPriority', setFlowConfigPriority)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if _G.availableAPIs.default and _G.availableAPIs.specific then

    _G.logger:fine(nameOfModule .. ': Try to initially load parameter from CSK_PersistentData module.')
    if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

      _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

      for j = 1, #multiWebSocketClient_Instances do
        multiWebSocketClient_Instances[j].persistentModuleAvailable = false
      end
    else
      -- Check if CSK_PersistentData version is >= 3.0.0
      if tonumber(string.sub(CSK_PersistentData.getVersion(), 1, 1)) >= 3 then
        local parameterName, loadOnReboot, totalInstances = CSK_PersistentData.getModuleParameterName(nameOfModule, '1')
        -- Check for amount if instances to create
        if totalInstances then
          local c = 2
          while c <= totalInstances do
            addInstance()
            c = c+1
          end
        end
      end

      if not multiWebSocketClient_Instances then
        return
      end

      for i = 1, #multiWebSocketClient_Instances do
        local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule, tostring(i))

        if parameterName then
          multiWebSocketClient_Instances[i].parametersName = parameterName
          multiWebSocketClient_Instances[i].parameterLoadOnReboot = loadOnReboot
        end

        if multiWebSocketClient_Instances[i].parameterLoadOnReboot then
          setSelectedInstance(i)
          loadParameters()
        end
      end
      Script.notifyEvent('MultiWebSocketClient_OnDataLoadedOnReboot')
    end
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

local function resetModule()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    clearFlowConfigRelevantConfiguration()
    pageCalled()
  end
end
Script.serveFunction('CSK_MultiWebSocketClient.resetModule', resetModule)
Script.register("CSK_PersistentData.OnResetAllModules", resetModule)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return funcs

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

