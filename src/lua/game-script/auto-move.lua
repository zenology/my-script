--[=====[
[[SND Metadata]]
author: 'Zenology'
version: 0.0.2
description: Auto Move - Script for Auto Move
plugin_dependencies:
- vnavmesh
[[End Metadata]]
--]=====]

local mountCondition = 4

if IPC.vnavmesh.IsReady() then
	if Player.CanFly then
		yield("/vnav flyflag")
	else
		yield("/vnav moveflag")
	end

	if not Svc.Condition[mountCondition] then
		-- Send Page Down button
		yield("/send NEXT")
	end
end
