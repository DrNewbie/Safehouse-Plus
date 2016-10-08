if not tweak_data then
	return
end

local _heistt = {"safehouse"}

for _, heist in pairs(_heistt) do
	tweak_data.narrative.jobs[heist] = {}
	tweak_data.narrative.jobs[heist] = deep_clone(tweak_data.narrative.jobs.rat)
	tweak_data.narrative.jobs[heist].name_id = tweak_data.levels[heist].name_id
	tweak_data.narrative.jobs[heist].briefing_id = tweak_data.levels[heist].briefing_id 
	tweak_data.narrative.jobs[heist].contact = "events"
	tweak_data.narrative.jobs[heist].region = "street"
	tweak_data.narrative.jobs[heist].package = tweak_data.levels[heist].package
	tweak_data.narrative.jobs[heist].chain = {
			{
				level_id = heist,
				type_id = "heist_type_assault",
				type = "d"
			}
		}
	tweak_data.narrative.jobs[heist].payout = {
		10,
		20,
		40,
		80,
		160,
		320,
		640
	}
	tweak_data.narrative.jobs[heist].contract_cost = {
		10,
		20,
		40,
		80,
		160,
		320,
		640
	}
	table.insert(tweak_data.narrative._jobs_index, heist)
end

_heistt = {}
