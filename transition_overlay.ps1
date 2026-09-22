# YTP+++ PowerShell plugin: Transition Overlay
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Transition Overlay'
        description = 'Overlays a random transition video on top of the current video.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Transition Overlay'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Overlays a random transition video on top of the current video.'
                type = 'label'
            },
            @{
                name = 'Opacity'
                value = '85'
                type = 'int'
                tooltip = 'Opacity of the transition overlay, from 0 to 100.'
            },
            @{
                name = 'Transition Scale'
                value = '100'
                type = 'int'
                tooltip = 'Scale of the transition video. 100 = fill the frame.'
            },
            @{
                name = 'Blend Mode'
                value = 'screen'
                type = 'string'
                tooltip = 'FFmpeg blend mode used for the transition.'
            },
            @{
                name = 'Transitions'
                value = ''''''
                type = 'video'
                tooltip = 'Video clips used as transition overlays.'
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
