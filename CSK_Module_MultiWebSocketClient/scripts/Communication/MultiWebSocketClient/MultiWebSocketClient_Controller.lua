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

local eventToForward = '' -- Preset event name to add via UI (see 'addEventToForwardViaUI')
local selectedEventToForward = '' -- Selected event to forward content on websocket within UI table

local multiWebSocketClient_Model -- Reference to model handle
local multiWebSocketClient_Instances -- Reference to instances handle
local selectedInstance = 1 -- Which instance is currently selected
local helperFuncs = require('Communication/MultiWebSocketClient/helper/funcs')

-- ************************ UI Events Start ********************************
-- Only to prevent WARNING messages, but these are only examples/placeholders for dynamically created events/functions
----------------------------------------------------------------
local function emptyFunction()
end
Script.serveFunction("CSK_MultiWebSocketClient.transmitDataNUM", emptyFunction)

Script.serveEvent("CSK_MultiWebSocketClient.OnNewDataNUM", "MultiWebSocketClient_OnNewDataNUM")
Script.serveEvent("CSK_MultiWebSocketClient.OnNewValueToForwardNUM", "MultiWebSocketClient_OnNewValueToForwardNUM")
Script.serveEvent("CSK_MultiWebSocketClient.OnNewValueUpdateNUM", "MultiWebSocketClient_OnNewValueUpdateNUM")
----------------------------------------------------------------

-- Real events
--------------------------------------------------
Script.serveEvent("CSK_MultiWebSocketClient.OnNewLog", "MultiWebSocketClient_OnNewLog")

Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusModuleVersion', 'MultiWebSocketClient_OnNewStatusModuleVersion')
Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusCSKStyle', 'MultiWebSocketClient_OnNewStatusCSKStyle')
Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusModuleIsActive', 'MultiWebSocketClient_OnNewStatusModuleIsActive')

Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusCurrentlyConnected', 'MultiWebSocketClient_OnNewStatusCurrentlyConnected')
Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusConnectionStatus', 'MultiWebSocketClient_OnNewStatusConnectionStatus')

Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusShowLog', 'MultiWebSocketClient_OnNewStatusShowLog')
Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusTempDataToTransmit', 'MultiWebSocketClient_OnNewStatusTempDataToTransmit')
Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusURL', 'MultiWebSocketClient_OnNewStatusURL')
Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusConnectionTimeout', 'MultiWebSocketClient_OnNewStatusConnectionTimeout')
Script.serveEvent('CSK_MultiWebSocketClient.OnNewStatusMessageFormat', 'MultiWebSocketClient_OnNewStatusMessageFormat')
Script.serveEvent("CSK_MultiWebSocketClient.OnNewEventToForwardList", "MultiWebSocketClient_OnNewEventToForwardList")
Script.serveEvent("CSK_MultiWebSocketClient.OnNewEventToForward", "MultiWebSocketClient_OnNewEventToForward")

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

-- ************************ UI Events End **********************************
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
  if parameter == 'currentConnectionStatus' then
    multiWebSocketClient_Instances[instance].isConnected = value
  end
  --multiWebSocketClient_Instances[instance].parameters.internalObject[selectedObject][parameter] = value
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

    Script.notifyEvent("MultiWebSocketClient_OnNewStatusCurrentlyConnected", multiWebSocketClient_Instances[selectedInstance].isConnected)
    Script.notifyEvent("MultiWebSocketClient_OnNewStatusConnectionStatus", multiWebSocketClient_Instances[selectedInstance].parameters.clientActivated)
    Script.notifyEvent("MultiWebSocketClient_OnNewStatusShowLog", multiWebSocketClient_Instances[selectedInstance].parameters.showLog)

    Script.notifyEvent("MultiWebSocketClient_OnNewStatusTempDataToTransmit", multiWebSocketClient_Instances[selectedInstance].dataToTransmit)
    Script.notifyEvent("MultiWebSocketClient_OnNewStatusURL", multiWebSocketClient_Instances[selectedInstance].parameters.url)
    Script.notifyEvent("MultiWebSocketClient_OnNewStatusConnectionTimeout", multiWebSocketClient_Instances[selectedInstance].parameters.timeout)
    Script.notifyEvent("MultiWebSocketClient_OnNewStatusMessageFormat", multiWebSocketClient_Instances[selectedInstance].parameters.messageFormat)

    Script.notifyEvent("MultiWebSocketClient_OnNewEventToForwardList", multiWebSocketClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiWebSocketClient_Instances[selectedInstance].parameters.forwardEvents))
    Script.notifyEvent("MultiWebSocketClient_OnNewEventToForward", '')

    Script.notifyEvent("MultiWebSocketClient_OnNewStatusFlowConfigPriority", multiWebSocketClient_Instances[selectedInstance].parameters.flowConfigPriority)
    Script.notifyEvent("MultiWebSocketClient_OnNewStatusLoadParameterOnReboot", multiWebSocketClient_Instances[selectedInstance].parameterLoadOnReboot)
    Script.notifyEvent("MultiWebSocketClient_OnPersistentDataModuleAvailable", multiWebSocketClient_Instances[selectedInstance].persistentModuleAvailable)
    Script.notifyEvent("MultiWebSocketClient_OnNewParameterName", multiWebSocketClient_Instances[selectedInstance].parametersName)
  end
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
  if multiWebSocketClient_Instances then
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
  Script.deregister("CSK_MultiWebSocketClient.OnNewValueUpdate" .. tostring(#multiWebSocketClient_Instances) , handleOnNewValueUpdate)
  Script.register("CSK_MultiWebSocketClient.OnNewValueUpdate" .. tostring(#multiWebSocketClient_Instances) , handleOnNewValueUpdate)
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

local function setShowLog(status)
  _G.logger:fine(nameOfModule .. ": Set showLog status to = " .. tostring(status))
  multiWebSocketClient_Instances[selectedInstance].parameters.showLog = status
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'showLog', status)
end
Script.serveFunction('CSK_MultiWebSocketClient.setShowLog', setShowLog)

local function setConnectionStatus(status)
  _G.logger:fine(nameOfModule .. ": Set websocket connection status to = " .. tostring(status))
  multiWebSocketClient_Instances[selectedInstance].parameters.clientActivated = status
  if status == true then
    Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'connect')
  else
    Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'disconnect')
  end
  Script.notifyEvent("MultiWebSocketClient_OnNewStatusConnectionStatus", multiWebSocketClient_Instances[selectedInstance].parameters.clientActivated)
end
Script.serveFunction('CSK_MultiWebSocketClient.setConnectionStatus', setConnectionStatus)

local function setConnectionTimeout(timeout)
  _G.logger:fine(nameOfModule .. ": Set conenction timeout = " .. tostring(timeout))
  multiWebSocketClient_Instances[selectedInstance].parameters.timeout = timeout
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'timeout', timeout)
end
Script.serveFunction('CSK_MultiWebSocketClient.setConnectionTimeout', setConnectionTimeout)

local function setServerURL(url)
  _G.logger:fine(nameOfModule .. ": Set websocket server URL = " .. tostring(url))
  multiWebSocketClient_Instances[selectedInstance].parameters.url = url
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'url', url)
end
Script.serveFunction('CSK_MultiWebSocketClient.setServerURL', setServerURL)

local function setMessageFormat(format)
  _G.logger:fine(nameOfModule .. ": Set message format of data to transmit = " .. tostring(format))
  multiWebSocketClient_Instances[selectedInstance].parameters.messageFormat = format
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'messageFormat', format)
end
Script.serveFunction('CSK_MultiWebSocketClient.setMessageFormat', setMessageFormat)

local function setDataToTransmit(data)
  _G.logger:fine(nameOfModule .. ": Preset data to transmit = " .. tostring(data))
  multiWebSocketClient_Instances[selectedInstance].dataToTransmit = data
end
Script.serveFunction('CSK_MultiWebSocketClient.setDataToTransmit', setDataToTransmit)

local function transmitDataViaUI()
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'transmit', multiWebSocketClient_Instances[selectedInstance].dataToTransmit)
end
Script.serveFunction('CSK_MultiWebSocketClient.transmitDataViaUI', transmitDataViaUI)

local function selectEventToForwardViaUI(selection)

  if selection == "" then
    selectedEventToForward = ''
    _G.logger:warning(nameOfModule .. ": Did not find EventToForward. Is empty")
  else
    local _, pos = string.find(selection, '"EventToForward":"')
    if pos == nil then
      _G.logger:warning(nameOfModule .. ": Did not find EventToForward. Is nil")
      selectedEventToForward = ''
    else
      pos = tonumber(pos)
      local endPos = string.find(selection, '"', pos+1)
      selectedEventToForward = string.sub(selection, pos+1, endPos-1)
      if ( selectedEventToForward == nil or selectedEventToForward == "" ) then
        _G.logger:warning(nameOfModule .. ": Did not find EventToForward. Is empty or nil")
        selectedEventToForward = ''
      else
        _G.logger:fine(nameOfModule .. ": Selected EventToForward: " .. tostring(selectedEventToForward))
        if ( selectedEventToForward ~= "-" ) then
          eventToForward = selectedEventToForward
          Script.notifyEvent("MultiWebSocketClient_OnNewEventToForward", eventToForward)
        end
      end
    end
  end
end
Script.serveFunction("CSK_MultiWebSocketClient.selectEventToForwardViaUI", selectEventToForwardViaUI)

local function addEventToForward(event)
  if ( event == '' ) then
    _G.logger:info(nameOfModule .. ": EventToForward cannot be added. Is empty")
  else
    multiWebSocketClient_Instances[selectedInstance].parameters.forwardEvents[event] = event
    Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'addEvent', event)
    Script.notifyEvent("MultiWebSocketClient_OnNewEventToForwardList", multiWebSocketClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiWebSocketClient_Instances[selectedInstance].parameters.forwardEvents))
  end
end
Script.serveFunction("CSK_MultiWebSocketClient.addEventToForward", addEventToForward)

local function addEventToForwardViaUI()
  addEventToForward(eventToForward)
end
Script.serveFunction("CSK_MultiWebSocketClient.addEventToForwardViaUI", addEventToForwardViaUI)

local function deleteEventToForward(event)
  multiWebSocketClient_Instances[selectedInstance].parameters.forwardEvents[event] = nil
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'removeEvent', event)
  Script.notifyEvent("MultiWebSocketClient_OnNewEventToForwardList", multiWebSocketClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiWebSocketClient_Instances[selectedInstance].parameters.forwardEvents))
end
Script.serveFunction("CSK_MultiWebSocketClient.deleteEventToForward", deleteEventToForward)

local function deleteEventToForwardViaUI()
  if selectedEventToForward ~= '' then
    deleteEventToForward(selectedEventToForward)
  end
end
Script.serveFunction("CSK_MultiWebSocketClient.deleteEventToForwardViaUI", deleteEventToForwardViaUI)

local function setEventToForward(value)
  eventToForward = value
  _G.logger:fine(nameOfModule .. ": Set eventToForward = " .. tostring(value))
end
Script.serveFunction("CSK_MultiWebSocketClient.setEventToForward", setEventToForward)

--- Function to share process relevant configuration with processing threads
local function updateProcessingParameters()
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'timeout', timeout)
  Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', selectedInstance, 'url', url)
  if multiWebSocketClient_Instances[selectedInstance].parameters.clientActivated == true then
    setConnectionStatus(true)
  end
end

local function getStatusModuleActive()
  return _G.availableAPIs.default and _G.availableAPIs.specific
end
Script.serveFunction('CSK_MultiWebSocketClient.getStatusModuleActive', getStatusModuleActive)

local function clearFlowConfigRelevantConfiguration()
  for i = 1, #multiWebSocketClient_Instances do
    if multiWebSocketClient_Instances[i].parameters.flowConfigPriority then
      for key, value in pairs(multiWebSocketClient_Instances[i].parameters.forwardEvents) do
        multiWebSocketClient_Instances[i].parameters.forwardEvents[key] = nil
        Script.notifyEvent('MultiWebSocketClient_OnNewProcessingParameter', i, 'removeEvent', value)
      end
    end
  end
  eventToForward = ''
  Script.notifyEvent("MultiWebSocketClient_OnNewEventToForwardList", multiWebSocketClient_Instances[selectedInstance].helperFuncs.createSpecificJsonList('eventToForward', multiWebSocketClient_Instances[selectedInstance].parameters.forwardEvents))
  pageCalled()
end
Script.serveFunction('CSK_MultiWebSocketClient.clearFlowConfigRelevantConfiguration', clearFlowConfigRelevantConfiguration)

local function stopFlowConfigRelevantProvider()
  for i = 1, #multiWebSocketClient_Instances do
    if multiWebSocketClient_Instances[i].parameters.flowConfigPriority then
      CSK_MultiWebSocketClient.setSelectedInstance(i)
      setConnectionStatus(false)
    end
  end
end
Script.serveFunction('CSK_MultiWebSocketClient.stopFlowConfigRelevantProvider', stopFlowConfigRelevantProvider)

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

      multiWebSocketClient_Instances[selectedInstance].parameters = helperFuncs.checkParameters(multiWebSocketClient_Instances[selectedInstance].parameters, helperFuncs.defaultParameters.getParameters())

      -- If something needs to be configured/activated with new loaded data
      updateProcessingParameters()

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
    for i = 1, #multiWebSocketClient_Instances do
      CSK_MultiWebSocketClient.setSelectedInstance(i)
      setConnectionStatus(false)
    end
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

