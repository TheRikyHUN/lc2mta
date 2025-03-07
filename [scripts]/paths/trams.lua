local files = {"tracks.dat","tracks2.dat"}
local paths = {}

-- http://wiki.multitheftauto.com/wiki/FindRotation
function findRotation(x1,y1,x2,y2)
 
  local t = -math.deg(math.atan2(x2-x1,y2-y1))
  if t < 0 then t = t + 360 end;
  return t;
 
end

function gotoNextPoint (i)
	local path = paths[i]
	if path[1] and path[1].x then
		local ox,oy,oz = getElementPosition(path.vehicle)
		local nx,ny,nz = path[1].x,path[1].y,path[1].z
		local distance = getDistanceBetweenPoints3D(ox,oy,oz,nx,ny,nz)
		local time = distance*100
		if time < 50 then
			time = 50
		end
		setElementRotation(path.vehicle,0,0,findRotation(ox,oy,nx,ny))
		moveObject(path.vehicle,time,nx,ny,nz)
		table.insert(path,path[1])
		table.remove(path,1)
		setTimer(gotoNextPoint,time,1,i)
	else
		destroyElement(path.vehicle)
		paths[i] = nil
	end
end

function createPaths ()
	for i,file in ipairs (files) do
		local f = fileOpen("paths/"..file)
		local content = fileRead(f,fileGetSize(f))
		fileClose(f)
		local vehicle
		local points = {}
		for i,line in ipairs (split(content,"\r\n")) do
			local words = split(line," ")
			if #words == 1 then
				id = tonumber(words[1])
				object = createObject(1337,0,0,0)
				vehicle = createVehicle(id,0,0,0)
				setTrainDerailed(vehicle,true)
				attachElements(vehicle,object)
				--createBlipAttachedTo(object)
				vehicle = object
			else
				table.insert(points,{x=tonumber(words[1])-336,y=tonumber(words[2]),z=tonumber(words[3])+2})
			end
		end
		local i = #paths+1
		paths[i] = points
		paths[i].vehicle = vehicle
		local ox,oy,oz = points[1].x,points[1].y,points[1].z
		local nx,ny,nz = points[2].x,points[2].y,points[2].z
		setElementPosition(vehicle,ox,oy,oz)
		setElementRotation(vehicle,0,0,findRotation(ox,oy,nx,ny))
		gotoNextPoint(i)
	end
end

addEventHandler("onClientResourceStart",root,
	function ()
		--createPaths()
		setTimer(createPaths,60000,6)
	end
)