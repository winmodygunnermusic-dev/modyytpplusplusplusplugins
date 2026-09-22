# YTP+++ PowerShell plugin: Sentence Mixing
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Sentence Mixing'
        description = 'Cuts, rearranges, reverses and stutters parts of the source audio for chaotic YTP-style sentence mixing.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Sentence Mixing'
                type = 'label'
            },
            @{
                name = 'Description'
                value = '"Cuts'
                type = 'label'
            },
            @{
                name = 'Chunk Count'
                value = '8'
                type = 'int'
                tooltip = 'Number of audio chunks to create.'
            },
            @{
                name = 'Chaos'
                value = '70'
                type = 'int'
                tooltip = 'How aggressively the chunks are randomized.'
            },
            @{
                name = 'Reverse Chance'
                value = '15'
                type = 'int'
                tooltip = 'Chance for an individual chunk to play backwards.'
            },
            @{
                name = 'Stutter Chance'
                value = '20'
                type = 'int'
                tooltip = 'Chance for an individual chunk to repeat.'
            },
            @{
                name = 'Stutter Repeats'
                value = '3'
                type = 'int'
                tooltip = 'Maximum number of times a selected chunk can repeat.'
            },
            @{
                name = 'Minimum Chunk'
                value = '0.12'
                type = 'float'
                tooltip = 'Minimum chunk duration in seconds.'
            },
            @{
                name = 'Maximum Chunk'
                value = '0.85'
                type = 'float'
                tooltip = 'Maximum chunk duration in seconds.'
            }
        )
    }
}

function StartGeneration {
    param($options, $pluginSettings, $functions)
    return $true
}

function PostCommand {
    param($commandIndex, $outputResult, $errorResult, $options, $pluginSettings, $functions)
}

function StopGeneration {
    param($options, $pluginSettings, $functions)
    return $true
}
