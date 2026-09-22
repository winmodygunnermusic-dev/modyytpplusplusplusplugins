# YTP+++ PowerShell plugin: Crossover Mashes
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Crossover Mashes'
        description = 'Cuts between crossover sections with random speed, reverse, stutter, zoom and glitch processing.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'effectName'
                type = 'label'
            },
            @{
                name = 'Description'
                value = '"Cuts between crossover sections with random speed'
                type = 'label'
            },
            @{
                name = 'Mash Intensity'
                value = '65'
                type = 'int'
                tooltip = 'Controls how aggressive the crossover editing becomes.'
            },
            @{
                name = 'Crossover Chance'
                value = '75'
                type = 'int'
                tooltip = 'Chance that a section receives a crossover transformation.'
            },
            @{
                name = 'Reverse Chance'
                value = '25'
                type = 'int'
                tooltip = 'Chance that an individual mash section is reversed.'
            },
            @{
                name = 'Speed Chaos'
                value = '1'
                type = 'bool'
                tooltip = 'Allows random fast and slow sections.'
            },
            @{
                name = 'Stutter'
                value = '1'
                type = 'bool'
                tooltip = 'Creates short repeated sections.'
            },
            @{
                name = 'Visual Glitch'
                value = '1'
                type = 'bool'
                tooltip = 'Adds RGB separation, frame blending and visual distortion.'
            },
            @{
                name = 'Hard Cuts'
                value = '1'
                type = 'bool'
                tooltip = 'Makes crossover boundaries more aggressive.'
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
