--[[

    Generates a new root, while making sure not
    to use an existing one, or its opposite

]]--

--- FUNCTIONS

-- Checks if a table contains an element
local function contains(table, value)
    for _,v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Picks a random element from a table
local function randLetter(table)
    return table[math.random(1, #table)]
end

--- PROGRAM START
local consonants = {'p', 't', 'k', 'm', 'n', 'f', 's', 'x', 'w', 'l', 'j'}
local vowels = {'i', 'u', 'a', 'e'}
local roots = {}

-- Init Rand
math.randomseed(os.time())
math.random()
math.random()
math.random()

-- Load words
for r in io.lines("dic.txt") do
    roots[#roots+1] = r
end
print("Loaded "..#roots.." roots.")

-- Generate the opposites
allRoots = {}
for _, r in ipairs(roots) do
    allRoots[#allRoots+1] = r
    allRoots[#allRoots+1] = string.reverse(r)
end
roots = allRoots
print("Generated "..(#allRoots/2).." Opposites")

print("How many new roots to generate?")
io.write(" > ")
numRoots = io.read()
io.write("\nRoots: ")

-- Generate new roots
for i = 1, numRoots do

    root = ""
    while root == "" or contains(roots, root) do
        onset = randLetter(consonants)
        coda = randLetter(consonants)
        while coda==onset do
            coda = randLetter(consonants)
        end

        root = onset.."_"..coda
    end

    if i==numRoots then
        io.write(root.."\n")
    else
        io.write(root..", ")
    end

end