-- Include all relevant FlowConfig scripts

--*****************************************************************
-- Here you will find all the required content to provide specific
-- features of this module via the 'CSK FlowConfig'.
--*****************************************************************

require('Communication/MultiWebSocketClient/FlowConfig/MultiWebSocketClient_OnReceive')
require('Communication/MultiWebSocketClient/FlowConfig/MultiWebSocketClient_Transmit')

--- Function to react if FlowConfig was updated
local function handleOnClearOldFlow()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    CSK_MultiWebSocketClient.clearFlowConfigRelevantConfiguration()
  end
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)

--- Function to react if FlowConfig was updated
local function handleOnStopProvider()
  if _G.availableAPIs.default and _G.availableAPIs.specific then
    CSK_MultiWebSocketClient.stopFlowConfigRelevantProvider()
  end
end
Script.register('CSK_FlowConfig.OnStopFlowConfigProviders', handleOnStopProvider)
