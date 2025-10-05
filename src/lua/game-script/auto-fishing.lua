--[=====[
[[SND Metadata]]
author: 'Zenology'
version: 1.2.1
description: HybridFishing - Script for Farming Cosmic Fishing Points
plugin_dependencies:
- AutoHook
- vnavmesh
- ICE
configs:
  mission:
    description: Class selection dropdown
    choices: ["Elemental-esque Aquaculture Specimens","EX: Large River Resources"]
    is_choice: true
    required: true
    default: "Elemental-esque Aquaculture Specimens"
  travelToLocation:
    default: true
    description: Indicate player must travel to mission location or not
    type: bool
    required: true
  baseReturnWaitTime:
    default: 8
    description: The time in second to waiting for Stellar Return to be finished
    type: integer
    required: true
[[End Metadata]]
--]=====]

import("System.Numerics")

-- Config
local canTravelConfig = Config.Get("travelToLocation")
local missionConfig = Config.Get("mission")
local baseReturnWaitTimeConfig = tonumber(Config.Get("baseReturnWaitTime"))

-- System
local missionCount = 0

-- Mission Info
local missionInfo = {
	["Elemental-esque Aquaculture Specimens"] = {
		["autohookPreset"] = "AH4_H4sIAAAAAAAACu1XS2/jOAz+K4HO1sJvy75lsp1ugfSBSYo5FHtQLDoR6lipLHenW+S/D2Rbje0kbVp0gAF2bw5FfiQ/kSLzjMaVEhNaqnKSLVHyjM4KushhnOcoUbICC+nDKS9gd8jM0QVDiUtiC91ILiRXTyhxLHRRnv1I84oB24m1/rbBuhQiXWmw+sPVXzVOSCx0vpmvJJQrkTOUOLbdQ34dusaIo56F/WYwk1W1NhH4ju2/EYKxEnkOqeoYOl019223QjJO8yOUOm4Y9kj1W7OvvFydPUHZcRwMIg6CXsShIZ3ew2zFM/WF8jpuLSiNYKZoel+iJGhpDMk+bhc1blFvqOJQpNCJJxzahX0GXWMq+b8woaopBeN1aO0O+Pda6/mK5pzel1/po5AaoCcw6XhWX/4NUvEIEiWOJulQLYdEl0DHoeHvC1+e03Wd6LhY5iBL40RfNkOJF9n+XvQ9KLLdWujsh5K07TTN/FzM/qGbi0JVXHFRnFNeGD6wY6FpJeESypIuASUIWeiqDgJdiQKQ1SA8bQAlmpgDeFNRqg/j3Ugo4XCECKMj543H+nwXz2wDqZI0n1RSQqE+KcsB6qflejDavYwPeq+1mgKZKbHR/cqL5UzBpn4Zd7G3RTSWnxNyF66O4bbgDxVoXMT8OKBuCjjzA4Z9SiK8ICnBdsZsNwgX4CxCtLXQlJfqOtM+SpTcNeWpE3gJMI6PRzjO81FjOgzzSsg1zf8S4l4DmRfjO9D6d9OE+rQEpTMx7diKGhzfifSTY4xnSopi+R5z2+uYT2EJBaPySSO0ii+PQUbzEqz3Ad+W8KeoWn2j2EhMnvpkztcgB6/OJS9ejlDixH/YFrou8qfvKyjGqeKPcMGgUDzVw+JABG6oiWl87Wg50VukvR2FO4WmA8a3Jcwl3/TJaCQfIaPvIQpcTXgD9xn59gDfn3Frrnt9nCmQE1otV2rK13rIOs3B8BGo96lKNlNcf3TGlbn6K6GO3P6BqeVFQTwc174enEeXEL0umQfbdOY3eKi4BDZTVFV6F9D72LBdT+vK9zZfT3G/b04o9pMLuKu1X5QnFdo7iucXVYm59P1t9fU77wwFO4N0AXGIXY962F+4NqaQZjjwwzAKiB/4hKHt32YqtDv73YugGQx3z6g7Ifwo8PzjM+J6Q3OuYHSx3kCZKiF7s8J5jaGXNtC0aHeNwngtqqKjdqA5/CAermVRf6kk2nElM5rCLNcPfZvMflMNt9Fga6Hf5t/Mbrf48EahjbVkolmtCe3uGO1moT8b8U7tUAF3ii0jlJEFEEyiOMI+8QiOSUQwo9S3Q3ex8ByGttZ+MXnHE5gIthYFrdT/RfTfKCJi21ngUIpDkgXYj50UUzvKcOhECxZlbsSCqH6xGlyzl47w6CyHNRSK5hjKhwpG44eKplWuKgkjvcXzNRR6b+3tzJ7r2szHKeiK9TwHEzsjOLCp7QQ0DAkwtP0JcrnZmj0RAAA=",
		["iceMissionId"] = 988,
		["locationId"] = 1,
	},
	["EX: Large River Resources"] = {
		["autohookPreset"] = "AH4_H4sIAAAAAAAACt1X227bOBD9FYPPEqArdXlzvU42gJsGdhZdINiHMTWyiciiS1FpvYH/vaAutuTIcRPkoegbTc6cOTM6nKGfybhUYgKFKibpisTPZJrDMsNxlpFYyRINog9nPMfjYdIe3SQkdsLIIHeSC8nVjsS2QW6K6Q+WlQkmx21tv6+xPgvB1hqsWjh6VeHQ0CDX2/u1xGItsoTEtmX1kF+HrjCioOdhXSQzWZebloFnW94FCq2XyDJkquNod82cy2GFTDhkZ0pqO5T2iuo1ble8WE93WHQC+yeMfb/HmLZFh0dcrHmqPgGveOuNot1YKGCPBYn9pow0fInbRY0a1DtQHHN2ThqebdFTGNovqNMiSf4/TkDVymhJnHo7J5/Dbbzv15BxeCyu4ElIDdDbaLNzjf7+HJl4QkliW9dsSNo01IroBGzL+YmvrmFT5T3OVxnKog2iv31CYjewvBfse1Dhfm+Q6Q8lobl4+kPci8V32N7kquSKi/waeN7Ww7QNMislfsaigBWSmBCD3FYkyK3IkRg1wm6LJNaFGcCbiUK9G+9OYoHDDIlJzpzXEavzI5/FFpmSkE1KKTFXH5TlCeqH5TrI9kXGg9Erq7k2mogyVyhrD23f6uxKSIaJjl7dGD/yfaPR1EKJrb7xPF8tFG6r3npMt9HdWH5Mll24ivY/Of9WosYlzLMiGoShmVALTc+zXRNcH0yaUJuBtYwcFpK9QWa8UF9SHaMg8UOtaJ3AgWAUnWc4zrJR7XpK81bIDWR/C/Gogdqe8xWh+l3fW316Utlmq8bx7EA3rdZ5oaTIV29xt9yO+wxXmCcgdxqhMTz0jxSyAo23Af8lymV2SOkMYs/RodHB75jNlzzbfV1jPmaKP+FNgrniTM+ZgdBdhF9JaMD5XvLtC9qNQeA77sHkyPAVoyESfTt9I8apQjmBcrVWM77Rw8yuD06vSvVuKWU9LfWiMwcGmr0b+NHL8f/KJNdvjrbNteKc47eSS0wWClSpB6p+1Jwq9teE+Vb9XdbTa8J5kzL+CAm895t3+qIDQF0a+KabeKnpLRk1I8aomXj2MkgAEpu5ZP9f2xibh+/DYaPujQ/PpNskvcCn9HybvJO82IDibDTJykKh7LVL+7UKHdqBLosOVxuMN3o2Hc2GHnJ+dPqYcfvvzFAHLmUKDBeZ7nVNMn7kX3jD+XuD/DZ/CY7j9d1DdfEdtnqnmvhVQbtjthmuellvH82GBNwRWxhEaWSnoRmhh6ZneUsT3Mg1l15KgQauw2y7EluN21Cc/jsyRzOQKxzN+RPK0RwLUUqGesx2pYzgICSumaSeZXoBBObSp5YJaeKmkWcH4FKy/wmpeLHMLg4AAA==",
		["iceMissionId"] = 992,
		["locationId"] = 3,
	},
}

local weatherMissionInfo = {
	["EX+: Stardust Bait Test"] = {
		["autohookPreset"] = "AH4_H4sIAAAAAAAACu1XTW/bOBD9KwavKxb6ICXKN9ebdgMkaVGn6ALFHmhxaHMjiy5FdZsN/N8X1IctObKzCHIodnOThsM3b0aPM9QDmlVWz3lpy7lcoekDuij4ModZnqOpNRV4yC1eqQLc4ociv6/fuVlB59DsEN3rpUDTkKUe+miUNsreo2ngocvy4keWVwLEwez8d02Aa62ztYtQP4TuqcaJmYfeb2/XBsq1zgWaBr4/QD4PXWOkyWCH/ySZ+bradAxI4JMnKHS7dJ5DZg81HFSEBH7Q3xU+zUIboXh+Ai8I43hQY9Jue6fK9cU9lL0E6FEClA4SiLtvwO9gsVbSvuWqTsMZys6wsDy7K9GUtlWN2WPcPmraon7kVkGRwem6xMcw8bC+YYdk1N8w57YRSkfieHd49HWidvftmueK35Xv+HdtHMDA0GUXeUP7J8j0dzBoGriadTHJIEJXv7dq9Z5v6kRnxSoHU3ao4eghiRKfPGI/QGa7nYcufljD28PpPsStXvzFt5eFrZRVunjPVdHVAwceuqoMXENZcndAEfLQTc0J3egCkNcg3G8BTV1hRvCudGmfjffRQAnjDBFGJ9abiPX6gc9iC5k1PJ9XxkBhXyjLI9QXy3WU7aOMR6PXXo1eFlZv3fFVxWphYVv3zQP3VlMz8zKU+3A1h8+F+laBw0U0FSCTkOE0ZhkmZEkxj1iMU5kkQsY0ooSinYeuVGk/SBejRNOvjTxdAnuCaXqa4SzPJ83WY5o32mx4/pvWdw6oayBfgNfvzl6C3R8oyfNyP4XaRZdgd9RaUwNPgsQ1pg5zYY0uemNvZPu1Kpz1Vm3qNhC/8T10zX/0bGHibEdh/KgX5gpWUAhu7s9G2kMe9YojBmSEQXSKwa+6WubHpWs8wjjdOxzqcNJlkMOI161R21OREhpGe5dTsQZOZ6K1fu6wzKQFM+fVam2v1MYNraBZOD5F9Z2lMs1UdA+9fj/amWn6eOqfmdjuqtG1s063n+BbpQyIheW2coPT3WVOiPkJcf5rbb1K4FkSeO4377VMwShlPM5wvGQSE+4TnAJjOAQRMpAslr5Euz+6ntned7/uDU3b/PqA+v2TJDEJT3fQd0bbtXT+/Q4anKvMpYDCqoznrhwuTOMw2+iq6LmNXdRoenxZiYb3SOYCV0byDBa5a2ttEjSlT9zR6M5DP80fwGHiPnvOus3OMndVrQvan7ztvHWPjfngNibcnsjAD0RC4xgTFjNMICOYJX6AwyhcUuaHdJkwtPMeiyg6ncBCC46XeQWTy80Wysxq8yqn/4ecBOV+JNII+ykNMAmAYJb5CY6XgQQIZRqScTmdSWC2Abu+L+3krfpTVy+upFfp/BzSSfwsCgmROEgShkkaZJhLssQ+kZQBcJGBPyIdws4k8LmwyuYgJl+0uZvc6DeTlL0K6D8qIJKCFCAplplMMAllipdJQHEgJGVBIJecBfV9qcFtKV78/ssETxaWG1G5HsOVndxCaYe/rynhIvFFjEXmxJnwEDNfUkyWkPqCQZRAgHb/AAprvf/7FAAA",
		["iceMissionId"] = 995,
		["locationId"] = 2,
	},
	["EX: Capsule Pools Distribution Survey"] = {
		["autohookPreset"] = "AH4_H4sIAAAAAAAACu1XTW/jNhD9KwbPYkFJJCX55vVm0wDebLBOsQWCHihpZBORRS9FpesG/u8F9WFL/oiRIIcCzY0eDh/fjB5nxs9oUhk1FaUpp9kCjZ/RVSHiHCZ5jsZGV+AguzmTBew3027rJkVjL4wcdKel0tJs0Nh10E159SvJqxTSvdn6bxusr0olSwtWLzy7qnF46KDr9f1SQ7lUeYrGLiED5Jeha4woGJwgF8lMl9WqY0BdQi9Q6E6pPIfEnMkIdYnbP+VdZqF0KkXeEXE9zgdJpa3fF1kurzZQ9hizA8aMDRjzLuniEeZLmZlPQta8raHsDHMjkscSjVmbRh4e4/ZRoxb1ThgJRXJOGtQl/BCGDxPqdUha/gNTYRpldCQOT3sHn8NvT98vRS7FY/lFPCltAQaGLjrfGdq/Q6KeQKOxa3N2Sto8tIroXdil85NcXItVHfekWOSgy+4S+7FTNPYDQo/YD6DC7dZBV7+MFu3Dsx/iXs3/FuubwlTSSFVcC1l0+cCug2aVhq9QlmIBaIyQg25rEuhWFYCcBmGzBjS2iTmBN1OleTPenYYSTjNEGJ3Zb26s9/d85mtIjBb5tNIaCvNOUR6gvlusJ9keRXzy9tqrEcjcqLV9vrJYzA2s60K5596KaKLfh3IfrubwRyF/VmBxESHUB8oY5n6YYepRD4uAJDhiGaMijDmPY7R10EyW5ltm7yjR+KGRpw1gRzCKzjOc5PmoOXpI81bplch/V+rRAnUF5AeI+re1l2B2bzETeQnd22w3bYDdK21NDTx1A1uYOsy50arotbQTx7/Kwlrv5cqWAY/8Ro4gid+DnMECilTozTtwrYE/qyrOD6NvPDwe7Rz2oZx1OUWt73Wv5frcTQHz/J3LubsGTi/c1vpZvU8yA3oqqsXSzOTK9h232Th8CPWIUemmsdlFr2R/K/LNjyUUt8pMEiOf4CaFwsjEtssmsScqtx+w6LiXv9CH7QDR1axOnN/hZyU1pHMjTGW7o51Qzij2ggJfK6oPkbxOJG/95r266NI4DCLXw0kgOKYeZDj0wxinnhv6iZeJlEVo+1dXGNsp9mFnaGrjwzPqF0kacNc7XyanYl1WOYxsaCrLBsXSPc5Pp/Czads9DQtoOTQOk5Wqip7bqVGNRYfjij+cJEPLp9KZSGCe26rWRsgidmFKY1sH/WeG/n3PfXOntYetZWqzWie033vbjmuXjXnvdqxq4tGBCBPiZmkYC0yCIMY0JT6OWeDjjCdeEIaCJ3GGts6xyPzLIpusYtAfEvu/S4wz5gLNfEyBU0xpLHAYZhlOeSQy1+dAXHZSYuSFGDaJkcnSLDflJYG9Wklvls5pCX4o6e6tShrIKI08wknCcRiHCaYs8HDog49j4gZpxhgPSVq3ywa3pXj15wiPuoJ0p1Rejj7L0mgZV3byGs0r/QSb4R8WBowEWeJjlqYepi4FLIIgwpxnQkQkTEWYoe2/8qoEkMkSAAA=",
		["iceMissionId"] = 993,
		["locationId"] = 4,
	},
}

local fishingLocation = {
	[1] = {
		["name"] = "the opalescent crossing",
		["walkingPoint"] = {},
		["fishingPosition"] = {
			Vector3(375.7061, 25.330305, -66.13579),
			Vector3(391.5525, 26.254713, -71.07592),
			Vector3(392.70184, 28.754503, -81.787224),
			Vector3(383.6726, 28.109919, -81.75077),
			Vector3(375.8509, 25.962015, -72.30614),
		},
		["return"] = false,
	},
	[2] = {
		["name"] = "the upper soda-lime float",
		["walkingPoint"] = {},
		["fishingPosition"] = {
			Vector3(-441.09396, -9.890936, -665.1347),
			Vector3(-440.65018, -9.230822, -678.6216),
			Vector3(-452.76883, -9.17243, -687.09766),
			Vector3(-459.23566, -9.2179, -682.23145),
		},
		["return"] = true,
	},
	[3] = {
		["name"] = "the lower soda-lime float",
		["walkingPoint"] = {},
		["fishingPosition"] = {
			Vector3(17.994, -12.195, 73.636),
			Vector3(6.849, -14.088, 56.940),
			Vector3(1.530, -12.784, 68.089),
			Vector3(44.493, -14.044, 136.824),
			Vector3(24.454, -14.329, 124.259),
		},
		["return"] = false,
	},
	[4] = {
		["name"] = "capsule pools",
		["walkingPoint"] = {
			Vector3(257.496, -8.950, 137.345),
			Vector3(291.390, -10.018, 143.230),
			Vector3(309.149, -9.156, 133.060),
		},
		["fishingPosition"] = {
			Vector3(679.44165, -255.6, 257.91476),
			Vector3(656.647, -255.6, 250.49129),
			Vector3(643.8695, -255.6, 283.16507),
			Vector3(612.97284, -255.6, 273.27692),
			Vector3(544.0758, -255.6, 397.0142),
			Vector3(501.26236, -255.60002, 429.36234),
			Vector3(522.0349, -255.6, 481.5189),
			Vector3(595.0503, -255.60002, 532.5266),
		},
		["return"] = true,
	},
}

-- ActionId
-- local cosmoboardActionId = 402
local mountActionId = 9
local unmountActionId = 23
local stellarReturn = 26

-- Condition index
local mountCondition = 4
local gatherCondition = 6
local fishingCondition = 43

-- Get all mission list and key list by looping
local missionList = {
	[missionConfig] = missionInfo[missionConfig],
}
local missionListKeys = { missionConfig }

for key, value in pairs(weatherMissionInfo) do
	missionList[key] = value
	table.insert(missionListKeys, key)
end

function hasValue(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

function isNotFishing()
	return not Svc.Condition[fishingCondition] and not Svc.Condition[gatherCondition]
end

function isNotMounted()
	return not Svc.Condition[mountCondition]
end

function isMissionSelected()
	local MissionName = Addons.GetAddon("_ToDoList"):GetNode(1, 72001, 2).Text

	if not MissionName then
		return false
	end

	if not hasValue(missionListKeys, MissionName) then
		return false
	end

	local isWindowOpened = Addons.GetAddon("WKSMissionInfomation").Ready

	if not isWindowOpened then
		yield("/click WKSHud Mission")

		wait(1)
	end

	return true
end

function wait(sec)
	yield("/wait " .. sec)
end

function randomWait(from, to)
	local waitTime = math.random(3, 5)

	wait(waitTime)
end

function waitForMissionSelected(checkMountStatus)
	if checkMountStatus then
		repeat
			wait(0.5)
		until isMissionSelected() and isNotFishing() and isNotMounted()
	else
		repeat
			wait(0.5)
		until isMissionSelected() and isNotFishing()
	end
end

-- #region base logic

local nextTimeReturn = false
function travelToMission(missionName)
	repeat
		wait(0.25)
	until IPC.vnavmesh.IsReady()

	-- Return if last mission need to travel back to base camp first
	if nextTimeReturn then
		nextTimeReturn = false
		Actions.ExecuteGeneralAction(stellarReturn)

		-- Wait until teleport finished
		wait(baseReturnWaitTimeConfig)

		wait(math.random(2, 4))
	end

	local locationId = missionList[missionName]["locationId"]
	local locationInfo = fishingLocation[locationId]

	if locationInfo then
		-- Initialize nextTimeReturn from location information
		nextTimeReturn = locationInfo["return"]

		local randomLocationIndex = math.random(1, #locationInfo["fishingPosition"])

		local paths = {}

		for key, value in pairs(locationInfo["walkingPoint"]) do
			table.insert(paths, value)
		end

		table.insert(paths, locationInfo["fishingPosition"][randomLocationIndex])

		if #paths > 1 then
			for key, value in pairs(paths) do
				Dalamud.Log("Vector Position" .. value.X)

				IPC.vnavmesh.PathfindAndMoveTo(value, false)

				-- Mount Cosmoboard
				if not Svc.Condition[mountCondition] then
					Actions.ExecuteGeneralAction(mountActionId)
				end

				repeat
					wait(0.25)
				until not IPC.vnavmesh.IsRunning()
			end
		else
			Dalamud.Log("Vector Position" .. paths[1].X)
			IPC.vnavmesh.PathfindAndMoveTo(paths[1], false)

			-- Mount Cosmoboard
			if not Svc.Condition[mountCondition] then
				Actions.ExecuteGeneralAction(mountActionId)
			end

			repeat
				wait(0.25)
			until not IPC.vnavmesh.IsRunning()
		end

		wait(1)

		-- Unmount Cosmoboard
		Actions.ExecuteGeneralAction(unmountActionId)
		wait(1)

		return true
	else
		Dalamud.Log("Error Occurred while navigating to fishing spot")
		return false
	end
end

local selectMissionName = nil
local isFirstTimeTraveling = true

function startMacro()
	-- Start ICE Command
	local iceMissionIds = ""
	for key, value in pairs(missionList) do
		iceMissionIds = iceMissionIds .. " " .. value["iceMissionId"]
	end

	Dalamud.Log("ICE mission Ids: " .. iceMissionIds)

	yield("/ice only" .. iceMissionIds)
	yield("/ice start")

	waitForMissionSelected(false)

	while true do
		local currentMission = Addons.GetAddon("WKSMissionInfomation"):GetNode(1, 3).Text

		if currentMission and currentMission ~= selectMissionName then
			-- Travel only determinie with config
			-- set to true will always traveling
			-- set to false will not traveling on the first time (Because of player is standing at the fishing pond)
			if canTravelConfig or (not canTravelConfig and not isFirstTimeTraveling) then
				Dalamud.Log('Travel to "' .. currentMission .. '" fishing spot')
				selectMissionName = currentMission

				local isSuccess = travelToMission(currentMission)

				-- Check if failed to navigate to location break the macro
				if not isSuccess then
					break
				end
			end

			-- Set this flag for the first time
			isFirstTimeTraveling = false

			Dalamud.Log("Initialize Autohook")
			IPC.AutoHook.DeleteAllAnonymousPresets()
			IPC.AutoHook.SetPluginState(false)
			IPC.AutoHook.CreateAndSelectAnonymousPreset(missionList[currentMission]["autohookPreset"])
			IPC.AutoHook.SetPluginState(true)

			Dalamud.Log(missionList[currentMission]["autohookPreset"])

			-- Fallback if player is mounted
			if not isNotMounted() then
				Actions.ExecuteGeneralAction(unmountActionId)
				wait(1)
			end

			waitForMissionSelected(true)
		end

		if isMissionSelected() and isNotFishing() then
			-- Fallback if player is mounted
			if not isNotMounted() then
				Actions.ExecuteGeneralAction(unmountActionId)
				wait(1)
			end

			missionCount = missionCount + 1

			Dalamud.Log("Mission Start: " .. currentMission .. " : " .. missionCount)
			-- Execute Fishing
			yield("/ahstart")

			waitForMissionSelected(true)
		end

		-- If Player is Idle and mission is selected trying to Report mission
		if isMissionSelected() and isNotFishing() then
			Dalamud.Log("Submit Report")
			yield("/click WKSMissionInfomation Report")

			waitForMissionSelected(true)
		end

		wait(0.25)
	end
end

-- #endregion

startMacro()
