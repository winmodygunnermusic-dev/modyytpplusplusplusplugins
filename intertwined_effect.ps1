# YTP+++ PowerShell plugin: Intertwined Effect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Intertwined Effect'
        description = 'Creates an intertwined woven effect by blending horizontally shifted copies of the video.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'effectName'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Creates an intertwined woven effect by blending horizontally shifted copies of the video.'
                type = 'label'
            },
            @{
                name = 'Shift'
                value = '18'
                type = 'int'
                tooltip = 'Horizontal pixel displacement used to intertwine the image.'
            },
            @{
                name = 'Blend'
                value = '0.50'
                type = 'float'
                tooltip = 'Blend strength between the original and shifted image.'
            },
            @{
                name = 'Wave'
                value = '10'
                type = 'int'
                tooltip = 'Amount of vertical wave distortion.'
            },
            @{
                name = 'Wave Length'
                value = '90'
                type = 'int'
                tooltip = 'Length of the horizontal wave pattern.'
            },
            @{
                name = 'Mirror'
                value = '0'
                type = 'bool'
                tooltip = 'Adds a mirrored copy to the intertwined image.'
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
