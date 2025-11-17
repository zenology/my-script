--[=====[
[[SND Metadata]]
author: 'Zenology'
version: 0.0.4
description: Auto Move - Script for Auto Move
plugin_dependencies:
- vnavmesh
[[End Metadata]]
--]=====]

local mountCondition = 4

if IPC.vnavmesh.IsReady() then
	if not Svc.Condition[mountCondition] then
		-- Send Page Down button
		yield("/send NEXT")
	end

	repeat
		yield("/wait 0.1")
	until Svc.Condition[mountCondition] or not Player.CanMount

	if Player.CanFly then
		yield("/vnav flyflag")
	else
		yield("/vnav moveflag")
	end
end
