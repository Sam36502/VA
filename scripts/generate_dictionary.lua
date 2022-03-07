--[[

    Script to generate the LaTeX code
    I need to make my dictionary

]]--

---- Constants ----
FORMAT_LETTER_TITLE = [[

\begin{center}
    \Huge{$letter$}
\end{center}
]]

FORMAT_ROOT_ENTRY = [[

\filbreak
{\Large\textbf{$root_title$} -- $english_def$} \\
\emph{Antonym: ``$ant_english_def$'' See $ant_root_title$} \\
\entry{$rfl$y$rll$}{"$rfp$i$rlp$}{v. ind.}{$vind$}
\entry{$rfl$ý$rll$}{"$rfp$y$rlp$}{v. imp.}{$vimp$}
\entry{$rfl$u$rll$}{"$rfp$u$rlp$}{n. sg.}{$nsing$}
\entry{$rfl$ú$rll$}{"$rfp$2$rlp$}{n. pl.}{$nplur$}
\entry{$rfl$a$rll$}{"$rfp$a$rlp$}{a. pos.}{$apos$}
\entry{$rfl$á$rll$}{"$rfp$\oe $rlp$}{a. sup.}{$asup$}
]]

FORMAT_EXTRA_ENTRY = [[
    \entry{$rfl$e$rll$}{"$rfp$e$rlp$}{$extra_pos$}{$extra_eng$}
]]

DICTIONARY_FILE = "dictionary.csv"

SUTLUN_CONSONANT_ORDER = "ptkmnfsxwlj"

---- Variables ----
AllRoots = {}

---- Functions ----
function LetterToPhoneme(letter)
    if letter == 'f' then
        return "\\textipa{F} "
    end

    return letter
end

-- normalize case of words in 'str' to Title Case
function Titlecase(str)
    local buf = {}
    for word in string.gfind(str, "%S+") do
        local first, rest = string.sub(word, 1, 1), string.sub(word, 2)
        table.insert(buf, string.upper(first) .. string.lower(rest))
    end    
    return table.concat(buf, " ")
end

function Split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function LoadWords()
    local isAntonym = false
    for r in io.lines(DICTIONARY_FILE) do
        local parts = Split(r, ";")

        local root = parts[1]:gsub("_", "-")
        local mode = parts[2]
        local vind = parts[3]
        local vimp = parts[4]
        local nsing = parts[5]
        local nplur = parts[6]
        local apos = parts[7]
        local asup = parts[8]

        local extra_pos, extra_eng = "", ""
        if #parts > 8 then
            extra_pos = parts[9]
            extra_eng = parts[10]
        end

        local english_def = Titlecase(vind..", "..nsing..", "..apos)
        local root_title = string.upper(root)
        local rootfirstletter = root:sub(1,1)
        local rootlastletter = root:sub(-1,-1)
        local rootfirstphoneme = LetterToPhoneme(rootfirstletter)
        local rootlastphoneme = LetterToPhoneme(rootlastletter)

        local newroot = {
            root        = root,
            mode        = mode,
            english_def = english_def,
            root_title  = root_title,
            rfl         = rootfirstletter,
            rll         = rootlastletter,
            rfp         = rootfirstphoneme,
            rlp         = rootlastphoneme,
            vind        = vind,
            vimp        = vimp,
            nsing       = nsing,
            nplur       = nplur,
            apos        = apos,
            asup        = asup,
            extra_pos   = extra_pos,
            extra_eng   = extra_eng,
        }

        if isAntonym then
            AllRoots[#AllRoots].ant_root_title = newroot.root_title
            AllRoots[#AllRoots].ant_english_def = newroot.english_def
            newroot.ant_root_title = AllRoots[#AllRoots].root_title
            newroot.ant_english_def = AllRoots[#AllRoots].english_def
        end

        AllRoots[#AllRoots+1] = newroot

        -- Every entry in the CSV is paired with its antonym directly below it
        isAntonym = not isAntonym
    end
end

function RenderTemplate(template, data)
    local render = template
    for key, value in pairs(data) do
        local keyStr = '%$'..key..'%$'
        render = render:gsub(keyStr, value)
    end
    return render
end

function IsRootHigherAlphabetically(root_a, root_b)
    if root_a.rfl == root_b.rfl then
        return SUTLUN_CONSONANT_ORDER:find(root_a.rll) < SUTLUN_CONSONANT_ORDER:find(root_b.rll)
    else
        return SUTLUN_CONSONANT_ORDER:find(root_a.rfl) < SUTLUN_CONSONANT_ORDER:find(root_b.rfl)
    end
end

function SortRoots()
    table.sort(AllRoots, IsRootHigherAlphabetically)
end

---- Main Program ----

print("Loading roots...")
LoadWords()
print("Done.\nLoaded "..#AllRoots.." roots.")

print("Sorting roots...")
SortRoots()
print("Done.")

Output_Filename = "output.txt"
print("Generating Dictionary to '"..Output_Filename.."'...")


File, E = io.open(Output_Filename, "w")
if File then
    local currLetter = ""
    for _, root in ipairs(AllRoots) do
        if root.rfl ~= currLetter then
            currLetter = root.rfl
            File:write(RenderTemplate(
                FORMAT_LETTER_TITLE,
                { letter = currLetter:upper() }
            ))
        end
        File:write(RenderTemplate(
            FORMAT_ROOT_ENTRY,
            root
        ))
        if root.extra_pos ~= "" then
            File:write(RenderTemplate(
            FORMAT_EXTRA_ENTRY,
            root
        ))
        end
    end
    File:close()
    print("Successfully created dictionary!\nBye!")
else
    print("Failed to open '"..Output_Filename.."'.\nBye!")
end