------Install ARK_01234 and PBOOT
function install_ark(_path)
	local pathsave = "ux0:/pspemu/PSP/SAVEDATA/"
	if not files.exists(pathsave) then files.mkdir(pathsave) end
	files.extract(files.cdir()+"/resources/ARK_01234.zip",pathsave)

	if not files.exists(_path) then	files.mkdir(_path) end
	if files.exists(_path.."/PBOOT.PBP") then files.rename(_path.."/PBOOT.PBP", "PBOOTXYZ.PBP") end
	files.copy(files.cdir()+"/resources/PBOOT.PBP",_path)
end

------Install PSP MINI NPUZ00146 (include ARK_01234 & PBOOT)
function install_ark_from0()
	buttons.homepopup(0)
		files.extract("resources/NPUZ00146/files_1.zip","ux0:/bgdl/t")
		files.extract("resources/NPUZ00146/files_2.zip","ux0:/pspemu/bgdl")
		install_ark(PATHTONPUZ)

		os.message("Your PSVita will restart...\n Remember to activate henkaku again",0)
		os.delay(3500)
	buttons.homepopup(1)
	power.restart()
end

-------Install ARK in BaseGame (include ARK_01234 & PBOOT) or Clone the PSP MINI NPUZ00146
function install_clone(id)
	buttons.homepopup(0)
	status = "Cloning"
	files.copy(PATHTOGAME+id,"ux0:/pspemu/")

	local i=0
	while files.exists(PATHTOGAME..string.format("%s%03d",string.sub("CNPEZ000",1,-3),i)) do
		i+=1
	end
	local lastid = string.format("%s%03d",string.sub("CNPEZ000",1,-3),i)

	files.rename("ux0:/pspemu/"+id, lastid)
	files.move("ux0:/pspemu/"+lastid, PATHTOGAME)

	status = ":)"
	
	if files.exists(PATHTOGAME+lastid) then
		if files.exists(PATHTOGAME+lastid+"/PBOOT.PBP") then
			local sfo = game.info(PATHTOGAME+lastid+"/PBOOT.PBP")
			if os.message("The PBOOT.PBP "..tostring(sfo.TITLE).." was found".."\n\nYou want to delete it from the clon? ",1) == 1 then
				files.delete(PATHTOGAME+lastid+"/PBOOT.PBP")
			end
		end
		update_db(0)
	else
		os.message("Error The clon can not be created",0)
		files.delete("ux0:/pspemu/"+lastid)
	end

	buttons.homepopup(1)
end
