# YTP+++ PowerShell plugin: Frame-by-Frame Masking
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Frame-by-Frame Masking'
        description = 'Applies an animated frame-by-frame geometric mask that changes position, size, and rotation.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Frame-by-Frame Masking'
                type = 'label'
            },
            @{
                name = 'Description'
                value = '"Applies an animated frame-by-frame geometric mask that changes position'
                type = 'label'
            },
            @{
                name = 'Mask Size'
                value = '55'
                type = 'int'
                tooltip = 'Base size of the animated mask.'
            },
            @{
                name = 'Movement'
                value = '35'
                type = 'int'
                tooltip = 'How far the mask moves around the frame.'
            },
            @{
                name = 'Rotation'
                value = '25'
                type = 'int'
                tooltip = 'Amount of mask rotation.'
            },
            @{
                name = 'Frame Chaos'
                value = '40'
                type = 'int'
                tooltip = 'Amount of frame-to-frame mask variation.'
            },
            @{
                name = 'Invert Mask'
                value = '0'
                type = 'bool'
                tooltip = 'Inverts the visible and hidden areas.'
            },
            @{
                name = 'Mask Shape'
                value = '0'
                type = 'int'
                tooltip = '0 = rectangle, 1 = circle, 2 = diamond.'
            },
            @{
                name = 'Chance Roll'
                value = '100'
                type = 'int'
                tooltip = 'Chance that the effect is applied.'
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
