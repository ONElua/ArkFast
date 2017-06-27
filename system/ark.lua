------Install ARK_01234 and PBOOT
function install_ark(_path)
	local pathsave = "ux0:/pspemu/PSP/SAVEDATA/"
	if not files.exists(pathsave) then files.mkdir(pathsave) end
	files.extract(files.cdir().."/resources/ARK_01234.zip",pathsave)

	if not files.exists(_path) then	files.mkdir(_path) end
	if files.exists(_path.."/PBOOT.PBP") then files.rename(_path.."/PBOOT.PBP", "PBOOTXYZ.PBP") end
	files.copy(files.cdir().."/resources/PBOOT.PBP",_path)
end

------Install PSP MINI NPUZ00146 (include ARK_01234 & PBOOT)
function install_ark_from0()
	buttons.homepopup(0)
		files.extract("resources/NPUZ00146/files_1.zip","ux0:/bgdl/t")
		files.extract("resources/NPUZ00146/files_2.zip","ux0:/pspemu/bgdl")
		install_ark(PATHTONPUZ)

		os.message("Your PSVita will restart...\n Remember to activate henkaku again",0)
		os.delay(2500)
	buttons.homepopup(1)
	power.restart()
end

function msg_memory(files_to_delete)
	files.delete(files_to_delete)
	os.message("Created "..count.." Clones\n\nTo eliminate Cloned bubbles please do it with ArkFast")
	update_db(false)
end

-------Clones
function install_clone(pathid,id,clons,delete_pboot)

	if files.exists(pathid.."/__sce_ebootpbp") and files.exists(pathid.."/EBOOT.PBP") then

		buttons.homepopup(0)
		local sizedir = files.size(pathid.."/__sce_ebootpbp") + files.size(pathid.."/EBOOT.PBP")

		if sizeUxo > sizedir then
			files.mkdir("ux0:pspemu/"..id)
			files.copy(pathid.."/__sce_ebootpbp","ux0:pspemu/"..id)
			files.copy(pathid.."/EBOOT.PBP","ux0:pspemu/"..id)

			if delete_pboot == false then
				if files.exists(pathid.."/PBOOT.PBP") then files.copy(pathid.."/PBOOT.PBP","ux0:pspemu/"..id) end
			end
		else
			os.message("Not Enough Memory")
			buttons.homepopup(1)
			return
		end

		--Update size
		sizedir = files.size("ux0:pspemu/"..id)

		count,status = 0,true
		for z=1,clons do
			local i=0
			while files.exists(PATHTOGAME..string.format("%s%03d",string.sub("CNPEZ000",1,-3),i)) do
				i+=1
			end
			local lastid = string.format("%s%03d",string.sub("CNPEZ000",1,-3),i)

			files.rename("ux0:pspemu/"..id, lastid)
			id = lastid

			if check_freespace() then
				if sizeUxo > sizedir then
					mgsid = lastid
					files.copy("ux0:pspemu/"..lastid, PATHTOGAME)
					count+=1
				else
					os.message("Not Enough Memory (minimum 40 MB)")
					if count > 0 then
						msg_memory("ux0:pspemu/"..id)
					else
						files.delete("ux0:pspemu/"..id)
						buttons.homepopup(1)
						return
					end
				end
			else
				os.message("Not Enough Memory (minimum 40 MB)")
				if count > 0 then
					msg_memory("ux0:pspemu/"..id)
				else
					files.delete("ux0:pspemu/"..id)
					buttons.homepopup(1)
					return
				end
			end
		end--for

		msg_memory("ux0:pspemu/"..id)
	else
		os.message("This bubble has no PBP files")
	end

end
