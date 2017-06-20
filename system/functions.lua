--------------------Check your Games (ONLY PSP GAMES)------------------------------------------------------
list = {data = {}, len = 0, icons = {}, picons = {} }

function reload_list()
	list.data = game.list(__PSPEMU)
	table.sort(list.data ,function (a,b) return string.lower(a.id)<string.lower(b.id); end)

	list.len = #list.data
	--Reversiva
	for i=list.len,1,-1 do
		local info = nil
		info = game.info(string.format("%s/eboot.pbp",list.data[i].path))
		
		if info then
			if info.CATEGORY and info.CATEGORY == "EG" then
				local img = nil
				local pimg = nil

				--Inicializar campos
				list.data[i].comp = "No"
				list.data[i].flag, list.data[i].del = 0, false
				list.data[i].clon = ""
				list.data[i].sceid, list.data[i].title = "Unk","Unk"

				if info.TITLE then list.data[i].title = info.TITLE end

				pimg = game.geticon0(string.format("%s/pboot.pbp",list.data[i].path))
				list.picons[i] = pimg

				img = game.geticon0(string.format("%s/eboot.pbp",list.data[i].path))
				if img then
					list.data[i].comp = "Yes"
					list.data[i].flag = 1
				end
				list.icons[i] = img

				sceid = game.sceid(string.format("%s/__sce_ebootpbp",list.data[i].path))
				if sceid and sceid != "---" then
					list.data[i].sceid = sceid
					if list.data[i].sceid != list.data[i].id then
						list.data[i].clon = "©"
						clon+=1
					end
				end

			else
				table.remove(list.data,i)
			end
		else
			table.remove(list.data,i)
		end
	end

	--Update
	list.len = #list.data
end

----------------------------Update DataBase-------------------------------------------------------------------
function update_db(_flag)
	os.delay(1500)
	os.updatedb()
	if _flag and _flag == 1 then
		os.message("Your PSVita will restart...\nRemember to activate Henkaku Again",0)
	else
		os.message("Your PSVita will restart...\nand your database will be rebuilt",0)
	end
	buttons.homepopup(1)
	os.delay(3500)
	power.restart()
end

------------------------Check your Free Space-------------------------------------------------------------------
function check_freespace()
	local info = os.devinfo("ux0:")
	if info and info.free > 40 * 1024* 1024 then
		sizeUxo = info.free
		return true
	else
		sizeUxo = 0
		return false
	end
end

function delete_bubble(_gameid)
	files.delete(PATHTOCLON+_gameid)
	files.delete(PATHTOGAME+_gameid)
end
