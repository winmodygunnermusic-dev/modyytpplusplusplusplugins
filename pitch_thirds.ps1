# YTP+++ PowerShell plugin: Pitch Thirds
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Pitch Thirds'
        description = 'Shifts the video''s audio by a musical third while keeping the original duration.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Pitch Thirds'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Shifts the video''s audio by a musical third while keeping the original duration.'
                type = 'label'
            },
            @{
                name = 'Pitch Direction'
                value = 'Random'
                type = 'string'
                tooltip = 'Choose whether the pitch goes upward, downward, or randomly.'
            },
            @{
                name = 'Intensity'
                value = '100'
                type = 'int'
                tooltip = '0 = no pitch shift, 100 = full major-third pitch shift.'
            },
            @{
                name = 'Randomize'
                value = '1'
                type = 'bool'
                tooltip = 'Randomly chooses upward or downward pitch thirds when enabled.'
            },
            @{
                name = 'Chance Roll'
                value = '100'
                type = 'int'
                tooltip = 'Percentage chance for the effect to use the pitch-third transformation.'
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
