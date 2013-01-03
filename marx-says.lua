
--[[
    Karl Marx quotes.
    Written by Daniel Keep.

    Copyright 2013.
    Released under the MIT license.

    Quotes sourced from: http://en.wikiquote.org/wiki/Karl_Marx
  ]]

--[[
    Usage: marx-says
  ]]

local args = {...}
local VERSION = 0.1

local QUOTES =
{
    [["History is not like some individual person, which uses men to achieve its ends. History is nothing but the actions of men in pursuit of their ends."]],
    [["The philosophers have only interpreted the world, in various ways. The point, however, is to change it."]],
    [["The classes and the races, too weak to master the new conditions of life, must give way."]],
    [["England has to fulfill a double mission in India: one destructive, the other regenerating - the annihilation of old Asiatic society, and the laying the material foundations of Western society in Asia."]],
    [["It's possible that I shall make an ass of myself. But in that case one can always get out of it with a little dialectic. I have, of course, so worded my proposition as to be right either way."]],
    [["Everyone who knows anything of history also knows that great social revolutions are impossible without the feminine ferment. Social progress may be measured precisely by the social position of the fair sex (plain ones included)."]],
    [["Neither of (Engels or I) cares a straw for popularity."]],
    [["Private property has made us so stupid and partial that an object is only ours when we have it, when it exists for us as capital ... Thus all the physical and intellectual senses have been replaced by ... the sense of having."]],
    [["Language comes into being, like consciousness, from the basic need, from the scantiest intercourse with other human."]],
    [["The history of all hitherto existing society is the history of class struggles."]],
    [["Law, morality, religion, are to him so many bourgeois prejudices, behind which lurk in ambush just as many bourgeois interests."]],
    [["The theory of Communism may be summed up in the single sentence: Abolition of private property."]],
    [["In place of the bourgeois society, with its classes and class antagonisms, shall we have an association, in which the free development of each is the condition for the free development of all."]],
    [["The proletarians have nothing to lose but their chains. They have a world to win. WORKING MEN OF ALL COUNTRIES, UNITE!"]],
    [["The object of art - like every other product - creates a public which is sensitive to art and enjoys beauty."]],
    [["A man cannot become a child again, or he becomes childish."]],
    [["Does this dress, worn by myself, reflect negatively upon my posterior?"]],
    [["The unity is brought about by force."]],
    [["The unity is brought about by The Force."]],
    [["Ideas do not exist separately from language."]],
    [["Who are you and why are you in my house?"]],
    [["The circulation of commodities is the original precondition of the circulation of money."]],
    [["Luxury is the opposite of the naturally necessary."]],
    [["Something that is merely negative creates nothing."]],
    [["We must construct additional pylons."]],
    [["The economic concept of value does not occur in antiquity."]],
    [["It is impossible to persue this nonsense any further."]],
    [["I pre-suppose, of course, a reader who is willing to learn something new and therefore to think for himself."]],
    [["The religious world is but the reflex of the real world."]],
    [["If production be capitalistic in form, so, too, will be reproduction."]],
    [["Every one knows that there are no real forests in England. The deer in the parks of the great are demurely domestic cattle, fat as London alderman."]],
    [["On the other hand one must not entertain any fantastic illusions on the productive power of the credit system, so far as it supplies or sets in motion money-capital."]],
    [["Capitalist production does not exist at all without foreign commerce."]],
    [["The process is so complicated that it offers ever so many occasions for running abnormally."]],
}

local i = math.random(#QUOTES)
print(QUOTES[i])

print("    -- Karl Marx")
print("")
