local json = game.HttpService:GetAsync("https://chrome-circular-crowd.glitch.me/superidol.json")
local get = game:GetService("HttpService"):JSONDecode(json)
local hertz = 440
local semitone = 1
function notetopitch(note) return (hertz/32)*math.pow(2,((note-semitone)/12))/hertz end
local online_sequencer = false
local usePresets = true;
local notes = {}
local notes2 = {}
local PresetManager = {Track1 = nil,Track2 = nil,Track3 = nil}
local Presets = {Flute = {sounds = {8837719860}},Piano = {sounds = {5924276201}}, Glockenspiel = {sounds = {9114133258}},
Misc = {sounds = {5915672378}}}
local Preset = {"Glockenspiel",1}
Preset = Presets[Preset[1]].sounds[Preset[2]]
if #get.tracks > 1 then
	if #get.tracks[1].notes == 0 then
		--Online Sequencer
		online_sequencer = true;
	end
end
local track = 0
if online_sequencer then
	track = 2
	notes = get.tracks[track].notes;
	if usePresets then
	--	print(get.tracks[].name)
	end
else
	track = 1
	notes = get.tracks[track].notes;
end
local current = 0
local all_notes = get.tracks[track].length;
local time_start = os.clock();
local speed = 0.75

local note = Instance.new("Sound",owner.Character.Head)
note.Volume = 1
LocalSounds = {
	"233836579", --C/C#
	"233844049", --D/D#
	"233845680", --E/F
	"233852841", --F#/G
	"233854135", --G#/A
	"233856105", --A#/B
}
print(Preset)
function LetterToNote(key, shift)
	local letterNoteMap = "1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"
	local capitalNumberMap = ")!@#$%^&*("
	local letter = string.char(key)
	if shift then
		if tonumber(letter) then
			-- is a number
			letter = string.sub(capitalNumberMap, tonumber(letter) + 1, tonumber(letter) + 1)
		else
			letter = string.upper(letter)
		end
	end
	local note = string.find(letterNoteMap, letter, 1, true)
	if note then
		return note
	end
end
function findKeyCode(value) local found = nil table.foreach(Enum.KeyCode:GetEnumItems(),function(i,v) if found==nil then if v.Value==tonumber(value) then found = v  end end end) return found end
local SoundList = LocalSounds
local can_play_note = {true,os.clock()};
local note_was_played = false
local where = Instance.new("Part",script)
where.CFrame = owner.Character.Torso.CFrame * CFrame.Angles(math.rad(-90),math.rad(90),0)
where.Orientation = Vector3.new(0,0,0)
where.Size = Vector3.new(1,1,1)
where.CanCollide = true
where.Anchored = false
where.Touched:Connect(function(h) if h.Anchored then return end where.Velocity = Vector3.new(0,14,0) where:ApplyImpulse(-(h.CFrame.p-where.CFrame.p).Unit*2) end)
local face = "176739335"
local vertex = "176739548"
local transparency = 0.2;
local beat_cf = where.CFrame;
local save = beat_cf
local textures = {}
table.foreach(Enum.NormalId:GetEnumItems(),function(i,v)
	local newface = Instance.new("Decal",where)
	newface.Transparency = transparency
	if v~= Enum.NormalId.Top and v~= Enum.NormalId.Bottom then
		newface.Texture = "rbxassetid://"..(face)
	else
		newface.Texture = "rbxassetid://"..(vertex)

	end
	newface.Face = tostring(v.Name)
	table.insert(textures,newface)
end)
local pitchband = 1
local smoother = false
local function toHMS(s)
	return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
end
print("Total song length | "..(toHMS(math.ceil(get.tracks[track].duration) / speed)))
function playNote(x,cleaner)
	local note2 = (x - 1)%12 + 1	-- Which note? (1-12)

	local octave = math.ceil(x/32)

	local sound = math.ceil(note2/2)-- Which audio?

	local offset = 16 * (octave - 1) + 8 * (1 - note2%2) -- How far in audio?
	local pitch = notetopitch(x)
	local sh = note:Clone()
	sh.Parent = where
	local things = {x=math.ceil(notes[current].midi),y=math.ceil(notes[current].midi),z=math.ceil(notes[current].midi)}
	local pick = math.random(1,3)
	local index = 0
	for i,v in pairs(things) do index+=1 if index~=pick then things[i] = 0 end end
	where.Color = Color3.fromRGB(255-things.x,255-things.y,255-things.z)
	table.foreach(textures,function(i,v) v.Color3 = where.Color end)
	if cleaner then
		sh.TimePosition =  offset + (octave-.9)/15 -- set the time position
		sh.SoundId = "rbxassetid://"..SoundList[sound];
		sh.Pitch = 1
		game:GetService("TweenService"):Create(sh,TweenInfo.new((2.3-(notes[current].velocity))),{Volume = 0}):Play()
	else
		sh.SoundId = "rbxassetid://"..DefaultSound;
		sh.Pitch = pitch
		sh.Volume = 0.8 * (0.6/notes[current].velocity)
		task.delay(1,function()
			game:GetService("TweenService"):Create(sh,TweenInfo.new(((notes[current].duration*2)/1) + 1,Enum.EasingStyle.Circular),{Volume = 0}):Play()
		end)
	end
	sh:Play()
	delay(4, function() sh:Stop() sh:Destroy() end ) -- remove the audio in 4 seconds, enough time for it to play
	note_was_played = true;
end
game:GetService("RunService").Heartbeat:Connect(function()

	if current>=all_notes then
		return
	end
	if current == 0 and (os.clock()-time_start)>tonumber(notes[1].time * (1/speed)) and can_play_note[1] then

		current +=1
		note_was_played = false;
		playNote(notes[current].midi,smoother)

	elseif (os.clock()-time_start)>tonumber(notes[current+1].time * (1/speed)) and can_play_note[1] and note_was_played then
		current+=1
		note_was_played = false;
		playNote(notes[current].midi,smoother)
	end
end)

--//
