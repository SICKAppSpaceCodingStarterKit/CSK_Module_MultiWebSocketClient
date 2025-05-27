-- Block namespace
local BLOCK_NAMESPACE = 'MultiWebSocketClient_FC.Process'
local nameOfModule = 'CSK_MultiWebSocketClient'

--*************************************************************
--*************************************************************

-- Required to keep track of already allocated resource
local instanceTable = {}

local function process(handle, source)

  local instance = Container.get(handle, 'Instance')

  -- Check if amount of instances is valid
  -- if not: add multiple additional instances
  while true do
    local amount = CSK_MultiWebSocketClient.getInstancesAmount()
    if amount < instance then
      CSK_MultiWebSocketClient.addInstance()
    else
      CSK_MultiWebSocketClient.setSelectedInstance(instance)
      CSK_MultiWebSocketClient.setRegisterEvent(source)
      break
    end
  end

  -- Return name of event providing internally processed data for other modules
  return 'CSK_MultiWebSocketClient.OnNewResult' .. tostring(instance)
end
Script.serveFunction(BLOCK_NAMESPACE .. '.process', process)

--*************************************************************
--*************************************************************

local function create(instance)

  local fullInstanceName = tostring(instance) -- .. tostring(mode) -- Optionally add parameters, check manifest as well

  -- Check if same instance is already configured
  if instanceTable[fullInstanceName] ~= nil then
    _G.logger:warning(nameOfModule .. "Instance invalid or already in use, please choose another one")
    return nil
  else
    -- Otherwise create handle and store the restriced resource
    local handle = Container.create()
    instanceTable[fullInstanceName] = fullInstanceName
    Container.add(handle, 'Instance', instance)
    --Container.add(handle, 'Mode', mode)
    return handle
  end
end
Script.serveFunction(BLOCK_NAMESPACE .. '.create', create)

--- Function to reset instances if FlowConfig was cleared
local function handleOnClearOldFlow()
  Script.releaseObject(instanceTable)
  instanceTable = {}
end
Script.register('CSK_FlowConfig.OnClearOldFlow', handleOnClearOldFlow)
