# YTP+++ PowerShell plugin: Sus
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Sus'
        description = 'Random sus-style visual distortion, zoom, shake, color chaos and audio weirdness.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Sus'
                type = 'label'
            },
            @{
                name = 'Description'
                value = '"Random sus-style visual distortion'
                type = 'label'
            },
            @{
                name = 'Intensity'
                value = '65'
                type = 'int'
                tooltip = 'Controls the overall strength of the sus effect.'
            },
            @{
                name = 'Visual Chaos'
                value = '70'
                type = 'int'
                tooltip = 'Controls random zoom, shake, color and distortion.'
            },
            @{
                name = 'Audio Chaos'
                value = '35'
                type = 'int'
                tooltip = 'Controls pitch and tempo distortion.'
            },
            @{
                name = 'Mirror Chance'
                value = '35'
                type = 'int'
                tooltip = 'Percentage chance that the clip will be horizontally mirrored.'
            },
            @{
                name = 'Vignette'
                value = '0'
                type = 'bool'
                tooltip = 'Adds a dark vignette around the image.'
            },
            @{
                name = 'Audio Distortion'
                value = '1'
                type = 'bool'
                tooltip = 'Enable strange pitch and tempo changes.'
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
