-- Include all relevant FlowConfig scripts

--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Communication/MultiWebSocketClient/FlowConfig/MultiWebSocketClient_Consumer')
require('Communication/MultiWebSocketClient/FlowConfig/MultiWebSocketClient_Provider')
require('Communication/MultiWebSocketClient/FlowConfig/MultiWebSocketClient_Process')


-- Reference to the multiWebSocketClient_Instances handle
local multiWebSocketClient_Instances

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    for i = 1, #multiWebSocketClient_Instances do
      if multiWebSocketClient_Instances[i].parameters.flowConfigPriority then
        CSK_MultiWebSocketClient.clearFlowConfigRelevantConfiguration()
        break
      end
    end
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to get access to the multiWebSocketClient_Instances
---@param handle handle Handle of multiWebSocketClient_Instances object
local function setMultiWebSocketClient_Instances_Handle(handle)
  multiWebSocketClient_Instances = handle
end

return setMultiWebSocketClient_Instances_Handle