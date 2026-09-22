# YTP+++ PowerShell plugin: YTP Tennis
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'YTP Tennis'
        description = 'Chaotic YTP tennis tournament effect with tournament '
        settings = @(
            @{
                name = 'Display Name'
                value = 'YTP Tennis'
                type = 'label'
            },
            @{
                name = 'Description'
                value = '"Chaotic YTP tennis tournament effect with tournament " ..'
                type = 'label'
            },
            @{
                name = 'Effect Chance'
                value = '75'
                type = 'int'
                tooltip = 'Percentage chance that the tennis effect becomes heavily chaotic.'
            },
            @{
                name = 'Chaos Level'
                value = '65'
                type = 'int'
                tooltip = 'Overall intensity from 0 to 100.'
            },
            @{
                name = 'Tournament Mode'
                value = '1'
                type = 'bool'
                tooltip = 'Adds a random tennis tournament identity to the effect.'
            },
            @{
                name = 'Use Tennis Overlay'
                value = '1'
                type = 'bool'
                tooltip = 'Uses a random clip from the Tennis Overlay library.'
            },
            @{
                name = 'Use Tennis SFX'
                value = '1'
                type = 'bool'
                tooltip = 'Uses a random tennis sound effect from the library.'
            },
            @{
                name = 'Speed Chaos'
                value = '1'
                type = 'bool'
                tooltip = 'Randomly speeds up or slows down tennis footage.'
            },
            @{
                name = 'Reverse Chaos'
                value = '1'
                type = 'bool'
                tooltip = 'Randomly reverses the clip.'
            },
            @{
                name = 'Stutter Chaos'
                value = '1'
                type = 'bool'
                tooltip = 'Repeats short sections to create a YTP stutter.'
            },
            @{
                name = 'Mirror Chaos'
                value = '1'
                type = 'bool'
                tooltip = 'Randomly mirrors the tennis footage.'
            },
            @{
                name = 'Color Chaos'
                value = '1'
                type = 'bool'
                tooltip = 'Adds hue, saturation and contrast distortion.'
            },
            @{
                name = 'Freeze Frames'
                value = '1'
                type = 'bool'
                tooltip = 'Randomly creates a brief frozen tennis moment.'
            },
            @{
                name = 'Tournament Text'
                value = '1'
                type = 'bool'
                tooltip = 'Adds the selected tournament name to the generated video.'
            },
            @{
                name = 'Tournament Name'
                value = ''
                type = 'string'
                tooltip = 'Optional fixed tournament name. Leave blank for random.'
            },
            @{
                name = 'Audio Mix'
                value = '0.80'
                type = 'float'
                tooltip = 'Volume multiplier for the optional tennis sound effect.'
            },
            @{
                name = 'Keep Audio'
                value = '1'
                type = 'bool'
                tooltip = 'Keep the original video''s audio.'
            },
            @{
                name = 'Debug Logging'
                value = '0'
                type = 'bool'
                tooltip = 'Prints YTP Tennis information to the NVG console.'
            },
            @{
                name = 'Tennis Tournament Clips'
                value = ''''''
                type = 'video'
                tooltip = 'Tennis League, Cup, Doubles, Triples and Multi-Way tournament clips.'
            },
            @{
                name = 'Tennis Overlays'
                value = ''''''
                type = 'video'
                tooltip = 'Tennis-themed transparent/green-screen overlays.'
            },
            @{
                name = 'Tennis SFX'
                value = ''''''
                type = 'audio'
                tooltip = 'Tennis hits, whistles, crowd reactions and tournament sounds.'
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
