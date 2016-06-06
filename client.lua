local core = require "core"
local C = require "CommandLineUI"

local tagsName = {}
local tagsId = {}

function initTags()
  tags = {}
  local sucess, msg, data = core.getTags()

  if (sucess) then
    for i=1,#data do
      tagsName[i] = data[i].name
      tagsId[i]= data[i].id
    end
  else
    error(msg)
  end
end

function getTagIdFromName(name)
  for i=1,#tagsName do
    if (name == tagsName[i]) then
      return tagsId[i]
    end
  end
end

initTags()
text   = C.ask("Enter task: ")
tagsName[#tagsName+1] = "None"
choice = C.choose("Which tag?", tagsName)

s,m,d = core.create_todo(text, getTagIdFromName(choice))
if (s == true) then
  print "Task successfully created"
end

