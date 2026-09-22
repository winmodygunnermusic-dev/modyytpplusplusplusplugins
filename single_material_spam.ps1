# YTP+++ PowerShell plugin: Single Material Spam
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Single Material Spam'
        description = 'Spams one material/color overlay repeatedly throughout the video.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'effectName'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Spams one material/color overlay repeatedly throughout the video.'
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '50'
                type = 'int'
                tooltip = 'Chance for the effect to activate.'
            },
            @{
                name = 'Opacity'
                value = '55'
                type = 'int'
                tooltip = 'Opacity of the material overlay from 0 to 100.'
            },
            @{
                name = 'Spam Count'
                value = '12'
                type = 'int'
                tooltip = 'Number of material flashes.'
            },
            @{
                name = 'Flash Duration'
                value = '0.08'
                type = 'float'
                tooltip = 'Duration of each material flash in seconds.'
            },
            @{
                name = 'Material Color'
                value = 'FF00FFFF'
                type = 'string'
                tooltip = 'FFmpeg color used for the material overlay.'
            },
            @{
                name = 'Blend Mode'
                value = 'screen'
                type = 'string'
                tooltip = 'FFmpeg blend mode for the material.'
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
