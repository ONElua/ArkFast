--------------------UNSAFE or SAFE-----------------------------------------------------------------------------
if os.access() == 0 then
	if os.master() == 1 then os.restart()
	else
		os.message("UNSAFE MODE is required for this HB!",0)
		os.exit()
	end
end
if files.exists("ux0:pspemu/temp/") then files.delete("ux0:pspemu/temp/") end

__NAMEVPK = "ArkFast"
dofile("updater.lua")

----------------------Vars and resources------------------------------------------------------------------------
color.loadpalette()
back = image.load("back.png")
buttonskey = image.load("buttons.png",20,20)
buttonskey2 = image.load("buttons2.png",30,20)
status,sizeUxo,clon,pos,dels=nil,0,0,1,0
actived = files.exists("tm0:npdrm/act.dat")

--constants
PATHTONPUZ = "ux0:pspemu/PSP/GAME/NPUZ00146"
PATHTOGAME = "ux0:pspemu/PSP/GAME/"
PATHTOCLON = "ur0:appmeta/"

dofile("system/ark.lua")
dofile("system/functions.lua")
dofile("system/callbacks.lua")

------------------------Menu Principal--------------------------------------------------------------------------------------
reload_list()
check_freespace()
files.mkdir(PATHTOGAME)
while true do
	buttons.read()
	if back then back:blit(0,0) end

	---------      Prints Text Basics      ----------------------------------
	screen.print(480,10,"ARK-2 Installer",1,color.white,color.blue,__ACENTER)
	screen.print(764,10,"Icon",1,color.white,color.blue)
	screen.print(862,10,"Pboot",1,color.white,color.blue)
	screen.print(10,10,"Count: " + list.len,1,color.red,0x0)

	--Show size free
	screen.print(950,480,"ux0: "..files.sizeformat(sizeUxo).." (Free)",1,color.white,color.blue,__ARIGHT)
	screen.print(950,502,"Minimum 40 MB",1,color.white,color.blue,__ARIGHT)

	if actived then
		screen.print(950,525,"PSVita Actived",1,color.green,0x0,__ARIGHT)
	else
		screen.print(950,525,"PSVita NOT Actived",1,color.red,0x0,__ARIGHT)
	end
	-------------------------------------------------------------------------

	status = ":)"
	if list.len > 0 then

		---------Controls---------------------------------------------------------------------------------------------------
		if buttons.up and pos > 1 then pos -= 1 end
		if buttons.down and pos < list.len then pos += 1 end

		if buttons.cross and list.data[pos].flag == 1 then
			if check_freespace() then
				if os.message("Install ARK in the game "..list.data[pos].id.." ?",1) == 1 then
					status = ":)"
					buttons.homepopup(0)
					install_ark(list.data[pos].path)									--function in ark.lua
					update_db(1)
				end
			else
				os.message("Not Enough Memory (minimum 40 MB)",0)
			end
		end

		if buttons.square and list.data[pos].flag == 1 then
			if check_freespace() then
				local sizedir = files.size(list.data[pos].path)
				if sizeUxo > sizedir then

					if os.message("Would you like to have this game cloned so you can install ARK \nor Adrenaline?",1) == 1 then
						install_clone(list.data[pos].id)
					end
				else
					os.message("Not Enough Memory",0)
				end
			else
				os.message("Not Enough Memory",0)
			end		
		end

		if buttons.triangle and list.data[pos].clon == "©" then
			list.data[pos].del = not list.data[pos].del
			if list.data[pos].del then dels+=1 else dels-=1 end
		end

		if buttons.circle and list.data[pos].clon == "©" then
			if list.data[pos].del then
				local state = os.message("Delete(s) "+dels+" this CLON(s) ??",1)
				if state == 1 then
					buttons.homepopup(0)
					for i=1,list.len do
						if list.data[i].del then
							os.message("Delete "..list.data[i].id,0)
							delete_bubble(list.data[i].id)
						end
					end
					update_db(0)
				end
			elseif dels==0  then
				local state = os.message("Delete this CLON: "+list.data[pos].id+" ?",1)
				if state == 1 then
					buttons.homepopup(0)
					delete_bubble(list.data[pos].id)
					update_db(0)
				end
			end
		end
		
		if buttons.select then
			for i=1,list.len do
				if list.data[i].del then
					list.data[i].del = false
					dels=0
				end
			end
		end

		if buttons.start then
			if check_freespace() then
				if files.exists(PATHTONPUZ+"/EBOOT.PBP") then
					os.message("The MINI Sasuke vs Commander is already installed",0)
				else
					install_ark_from0()
				end
			else
				os.message("Not Enough Memory (minimum 40 MB)",0)
			end
		end
		---------Controls-----------------------------------------------------------------------------------------------------

		--------------------Blit Icons----------------------------------------------------------------------------------------
		if list.icons[pos] then
			list.icons[pos]:center()
			list.icons[pos]:resize(80,80)
			list.icons[pos]:blit(950-230 + 64,35 + 64)
		end

		--Pboot
		if list.picons[pos] then
			list.picons[pos]:center()
			list.picons[pos]:resize(80,80)
			list.picons[pos]:blit(950-128 + 64,35 + 64)
		end

		local y = 65
		for i=pos,math.min(list.len,pos+19) do

			if i == pos then screen.print(10,y,"->") end
			screen.print(40,y,string.format("%02d",i)+' '+list.data[i].id or "unk")

			if list.data[i].flag == 1 then ccolor=color.green else ccolor=color.red end
			screen.print(215,y,list.data[i].comp or "unk",1,ccolor,0x0,__ALEFT)

			screen.print(260,y,list.data[i].title or "unk",1,color.white,0x0,__ALEFT)

			if list.data[i].del then draw.fillrect(36,y,677,16,color.new(255,255,255,100)) end

			screen.print(710,y,list.data[i].sceid or "",1,color.white,0x0,__ARIGHT)
			screen.print(735,y,list.data[i].clon or "",1,color.green,0x0,__ARIGHT)

			y += 20
		end

		if clon>=1 and list.data[pos].clon == "©" then
			if dels>=0 or list.data[pos].del then
				if buttonskey then buttonskey:blitsprite(10,417,3) end					--Circulo
				screen.print(45,420,"Delete CLON(s)",1,color.white,color.blue)
			end

			if buttonskey then buttonskey:blitsprite(10,442,1) end						--Triangulo
			screen.print(45,444,"Mark/Unmark CLON(s) to be deleted /SELECT Unmark all",1,color.white,color.blue)

		end

		if list.data[pos].flag == 1 then
			if buttonskey then buttonskey:blitsprite(10,465,0) end						-- X
			screen.print(45,468,"Install ARK",1,color.white,color.blue)
		end

		if list.data[pos].flag == 1 then
			if buttonskey then buttonskey:blitsprite(10,488,2) end						-- []
			screen.print(45,490,"Clone Game",1,color.white,color.blue)
		end

		if buttonskey2 then buttonskey2:blitsprite(5,508,1) end
		screen.print(45,510,"Install the MINI Sasuke vs Commander with ARK",1,color.white,color.blue)

	else
		screen.print(10,480,"No games PSP :(")
		if buttonskey then
			buttonskey:blitsprite(10,508,0)
		end
		screen.print(10,510,"Install the MINI Sasuke vs Commander and install ARK",1,color.white,color.blue)

		if buttons.cross then 
			if check_freespace() then install_ark_from0()
			else
				os.message("Not Enough Memory (minimum 40 MB)",0)
			end
		end
	end

	screen.flip()
end
