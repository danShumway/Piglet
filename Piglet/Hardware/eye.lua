--
--Licensed under GNU affero general public license
--http://www.gnu.org/licenses/agpl-3.0.html
--

local eye = {}


local frame = {}
function eye.getFrame()
	frame = memory.readbyterange(0, 256*16*16)
	return frame
end

return eye