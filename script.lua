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

----------------------Vars and resources------------------------------------------------------------------------------------
color.loadpalette()
back = image.load("back.png")
buttonskey = image.load("buttons.png",20,20)
buttonskey2 = image.load("buttons2.png",30,20)
status,sizeUxo,clon,pos,dels=false,0,0,1,0
actived = files.exists("tm0:npdrm/act.dat")
mgsid=""

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
buttons.interval(10,10)

while true do
	buttons.read()
	if back then back:blit(0,0) end

	---------      Prints Text Basics      ---------------------------------------------------------------------------------
	if actived then
		screen.print(480,10,"PSVita Actived",1,color.green,0x0,__ACENTER)
	else
		screen.print(480,10,"PSVita NOT Actived",1,color.red,0x0,__ACENTER)
	end
	screen.print(480,35,"ARK-2 Installer",1,color.white,color.blue,__ACENTER)

	screen.print(10,10,"Count: " .. list.len,1,color.red,0x0)
	screen.print(10,30,"Sel Clons: " .. dels,1,color.red,0x0)

	--Show size free
	screen.print(950,10,"ux0: "..files.sizeformat(sizeUxo).." Free",1,color.white,color.blue,__ARIGHT)

	status = false
	if list.len > 0 then

		--------------------Blit Icons--------------------------------------------------------------------------------------
		if list.icons[pos] then
			list.icons[pos]:center()
			list.icons[pos]:resize(80,80)
			list.icons[pos]:blit(784,125)
		end

		--Pboot
		if list.picons[pos] then
			list.picons[pos]:center()
			list.picons[pos]:resize(80,80)
			list.picons[pos]:blit(886,125)
		end

		local y = 85
		for i=pos,math.min(list.len,pos+14) do

			if i == pos then screen.print(10,y,"->") end
			screen.print(40,y,list.data[i].id or "unk")

			if list.data[i].flag == 1 then ccolor=color.green else ccolor=color.red end
			screen.print(195,y,list.data[i].comp or "unk",1,ccolor,0x0,__ALEFT)

			screen.print(245,y,list.data[i].title or "unk",1,color.white,0x0,__ALEFT)

			if list.data[i].del then draw.fillrect(33,y,700,16,color.new(255,255,255,100)) end

			screen.print(700,y,list.data[i].sceid or "",1,color.white,0x0,__ARIGHT)
			screen.print(725,y,list.data[i].clon or "",1,color.green,0x0,__ARIGHT)

			y += 20
		end

		--------------------Left--------------------------------------------------------------------------------------------
		if buttonskey then buttonskey:blitsprite(10,465,0) end											-- X
		screen.print(45,468,"Install ARK",1,color.white,color.blue)

		if buttonskey then buttonskey:blitsprite(10,488,2) end											-- []
		screen.print(45,490,"Clone Game",1,color.white,color.blue)

		if buttonskey2 then buttonskey2:blitsprite(5,508,1) end											--Start
		screen.print(45,510,"Install the MINI Sasuke vs Commander & ARK2",1,color.white,color.blue)

		--------------------Right-------------------------------------------------------------------------------------------
		if buttonskey then buttonskey:blitsprite(930,465,3) end											--Cirle
		screen.print(920,468,"Delete CLON(s)",1,color.white,color.blue, __ARIGHT)

		if buttonskey then buttonskey:blitsprite(930,488,1) end											--Triangle
		screen.print(920,490,"Mark/Unmark CLON(s) to be deleted",1,color.white,color.blue, __ARIGHT)
		
		if dels > 0 then
			if buttonskey then buttonskey2:blitsprite(923,508,0) end									--Select
			screen.print(920,510,"Unmark all CLON(s)",1,color.white,color.blue, __ARIGHT)
		end

	else
		screen.print(10,480,"No games PSP :(")
		if buttonskey then
			buttonskey:blitsprite(10,508,0)
		end
		screen.print(10,510,"Install the MINI Sasuke vs Commander and install ARK",1,color.white,color.blue)

		if buttons.cross then 
			if check_freespace() then install_ark_from0()
			else
				os.message("Not Enough Memory (minimum 40 MB)")
			end
		end
	end

	---------Controls-------------------------------------------------------------------------------------------------------
		if (buttons.up or buttons.analogly < -60) and pos > 1 then pos -= 1 end
		if (buttons.down or buttons.analogly > 60) and pos < list.len then pos += 1 end

		if buttons.cross and list.data[pos].flag == 1 then
			if check_freespace() then
				if os.message("Install ARK in the game "..list.data[pos].id.." ?",1) == 1 then
					status = false
					buttons.homepopup(0)
					install_ark(list.data[pos].path)
					update_db(true)
				end
			else
				os.message("Not Enough Memory (minimum 40 MB)")
			end
		end

		if buttons.square and list.data[pos].flag == 1 then
			if check_freespace() then
				delp = false
				if os.message("Would you like to have this game cloned so you can install ARK \nor Adrenaline?",1) == 1 then

					if files.exists(PATHTOGAME..list.data[pos].id.."/PBOOT.PBP") then
						local sfo = game.info(PATHTOGAME..list.data[pos].id.."/PBOOT.PBP")
						if os.message("PBOOT.PBP: "..tostring(sfo.TITLE).." was found".."\n\nYou want to delete it ?\n\nClones will be clean ",1) == 1 then
							delp = true
						end
					end

					number_clons = math.minmax(tonumber(osk.init("Create Clones (1 to 9)","1",2,1)),1,9)
					install_clone(list.data[pos].path, list.data[pos].id, number_clons, delp)		
				end--os.message
			else
				os.message("Not Enough Memory (minimum 40 MB)")
			end		
		end

		if buttons.triangle and list.data[pos].clon == "©" then
			list.data[pos].del = not list.data[pos].del
			if list.data[pos].del then dels+=1 else dels-=1 end
		end

		if buttons.circle and list.data[pos].clon == "©" then
			if list.data[pos].del then
				if os.message("Delete(s) "..dels.." this CLON(s) ??",1) == 1 then
					buttons.homepopup(0)
					for i=1,list.len do
						if list.data[i].del then
							delete_bubble(list.data[i].id)
						end
					end
					os.message("Ready..."..dels.."\n\nCLON(s) Eliminated(s)")
					update_db(false)
				end
			elseif dels==0  then
				if os.message("Delete this CLON: "..list.data[pos].id.." ?",1) == 1 then
					buttons.homepopup(0)
					delete_bubble(list.data[pos].id)
					update_db(false)
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
				if files.exists(PATHTONPUZ.."/EBOOT.PBP") then
					os.message("The MINI Sasuke vs Commander is already installed",0)
				else
					install_ark_from0()
				end
			else
				os.message("Not Enough Memory (minimum 40 MB)")
			end
		end
		---------Controls---------------------------------------------------------------------------------------------------

	screen.flip()
end
