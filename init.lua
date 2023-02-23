local S = minetest.get_translator(minetest.get_current_modname())
heat_trans = {}
heat_trans.max_temp = 212--boiling point water... seems a  good max
heat_trans.min_temp = 1--woulda done 0 but that happens to be what meta:get_float returns if nil :P
heat_trans.room_temp = 75--room temp defined by someone(not me)

heat_trans.reg_ht = {}

function int(num)
    return math.floor(num)
end


local toggle_timer = function (pos)
	local timer = minetest.get_node_timer(pos)
	if timer:is_started() then
		timer:stop()
	else
		timer:start(.5)
	end
end

local on_timer = function (pos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
            
    local self_temp = meta:get_float('heat_trans:temp')
    if self_temp==0 then
        meta:set_float('heat_trans:temp',heat_trans.room_temp)--if empty set to room temp
        self_temp = meta:get_float('heat_trans:temp')
    end
    minetest.log('loop')
    for x = -1,1 do
        for y = -1,1 do
            for z = -1, 1 do
                local p = {x = pos.x+x, y = pos.y+y, z = pos.z+z}
                local m = minetest.get_meta(p)
                local t = m:get_float('heat_trans:temp')
                if t~=0 then
                    if t>self_temp and t>heat_trans.min_temp then
                        self_temp = self_temp+1
                        t = t-1 
                    end
                    if t<self_temp and t<heat_trans.max_temp then
                        self_temp = self_temp-1.01
                        t = t+1
                    end
                    --meta:set_float('heat_trans:temp',self_temp)
                    m:set_float('heat_trans:temp', t)
                    m:set_string("infotext", "temp = "..tostring(int(t)))
                else
                    m:set_float('heat_trans:temp', heat_trans.room_temp)
                end
            end
        end
    end
    --meta:set_string("infotext", "temp = "..tostring(int(self_temp)))
end

minetest.register_on_mods_loaded(function()
    local def = minetest.registered_nodes['air']-- reg air no matter what
    def.on_timer = on_timer

    for name,val in pairs(heat_trans.reg_ht) do
        if val==true then--just incase something messes with it
            local def = minetest.registered_nodes[name]
            def.on_timer = on_timer
        end
    end

end)

minetest.register_node('heat_trans:heat_block', {
    description=S('POC node for the idea'),
    use_texture_alpha = "clip",
    tiles={'heat_trans_h_b.png'},
    groups={oddly_breakable_by_hand=1},
    drawtype = "glasslike_framed_optional",
	use_texture_alpha = "clip", -- only needed for stairs API
	paramtype = "light",
	sunlight_propagates = true,
    is_ground_content = false,
    backface_culling=false,
})
minetest.register_node('heat_trans:hb_max', {
    description=S('High temp block'),
    use_texture_alpha = "clip",
    tiles={'heat_trans_h_b.png^[colorize:#dc1818:250'},
    drawtype = "glasslike_framed_optional",

    paramtype = "light",
	sunlight_propagates = true,
    is_ground_content = false,
    groups={oddly_breakable_by_hand=1}
})
minetest.register_node('heat_trans:hb_min', {
    description=S('Low temp block'),
    use_texture_alpha = "clip",
    tiles={'heat_trans_h_b.png^[colorize:#0063b0:250'},
    drawtype = "glasslike_framed_optional",

    paramtype = "light",
	sunlight_propagates = true,
    is_ground_content = false,
    groups={oddly_breakable_by_hand=1}
})
function heat_trans.register_ht_node(name)
    heat_trans.reg_ht[name]=true
end
function heat_trans.register_hot_node(name)
    heat_trans.reg_ht[name]=false

    minetest.register_abm({
        nodenames = {name},
        interval = 0.5,
        chance = 1,
        action = function(pos)
            local meta = minetest.get_meta(pos)
            meta:set_float('heat_trans:temp', heat_trans.max_temp)
        end
    })
end
function heat_trans.register_cold_node(name)
    heat_trans.reg_ht[name]=false
    minetest.register_abm({
        nodenames = {name},
        interval = 0.5,
        chance = 1,
        action = function(pos)
            local meta = minetest.get_meta(pos)
            meta:set_float('heat_trans:temp', heat_trans.min_temp)
        end
    })
end
--heat_trans.register_ht_node('air')
heat_trans.register_ht_node('heat_trans:heat_block')

heat_trans.register_hot_node("heat_trans:hb_max")
--heat_trans.register_hot_node("default:lava_source")
--heat_trans.register_hot_node("default:lava_flowing")

heat_trans.register_cold_node("heat_trans:hb_min")
--heat_trans.register_cold_node("default:water_source") -- why not :P
--heat_trans.register_cold_node("default:water_flowing")
