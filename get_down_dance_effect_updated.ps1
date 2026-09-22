# YTP+++ PowerShell plugin: Get Down Dance Effect Updated
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Get Down Dance Effect Updated'
        description = 'Adds a rhythmic get-down dance effect with bouncing zoom, camera movement, rotation, shake and optional audio punch.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'effectName'
                type = 'label'
            },
            @{
                name = 'Description'
                value = '"Adds a rhythmic get-down dance effect with bouncing zoom'
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '100'
                type = 'int'
                tooltip = 'Chance from 0-100 for the effect to activate.'
            },
            @{
                name = 'Dance Intensity'
                value = '70'
                type = 'int'
                tooltip = 'Controls the strength of the dance movement.'
            },
            @{
                name = 'Dance Speed'
                value = '2.5'
                type = 'float'
                tooltip = 'Controls how quickly the dance motion repeats.'
            },
            @{
                name = 'Speed Up'
                value = '1'
                type = 'bool'
                tooltip = 'Slightly speeds up the video for a more energetic dance.'
            },
            @{
                name = 'Audio Punch'
                value = '1'
                type = 'bool'
                tooltip = 'Adds a small audio volume boost.'
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
