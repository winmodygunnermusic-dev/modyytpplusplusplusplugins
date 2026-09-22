# YTP+++ PowerShell plugin: Evil
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Evil'
        description = 'Turns the video into a sinister evil-themed effect with dark colors, red highlights, contrast, distortion, and unsettling audio.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Evil'
                type = 'label'
            },
            @{
                name = 'Description'
                value = '"Turns the video into a sinister evil-themed effect with dark colors'
                type = 'label'
            },
            @{
                name = 'Darkness'
                value = '70'
                type = 'int'
                tooltip = 'Controls how dark the evil effect becomes.'
            },
            @{
                name = 'Red Intensity'
                value = '75'
                type = 'int'
                tooltip = 'Controls the amount of red coloring.'
            },
            @{
                name = 'Audio Evil'
                value = '1'
                type = 'bool'
                tooltip = 'Adds a darker, lower-pitched audio treatment.'
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
