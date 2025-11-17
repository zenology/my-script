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
	if not Svc.Condition[mountCondition] and Player.CanMount then
		-- Send Page Down button
		yield("/send NEXT")

		repeat
			yield("/wait 0.1")
		until Svc.Condition[mountCondition]
	end

	if Player.CanFly then
		yield("/vnav flyflag")
	else
		yield("/vnav moveflag")
	end
end
