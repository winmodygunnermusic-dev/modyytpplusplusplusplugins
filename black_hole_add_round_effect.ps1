# YTP+++ PowerShell plugin: Black Hole Add Round Effect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Black Hole Add Round Effect'
        description = 'Black Hole Add Round Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Black Hole Add Round Effect'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Black Hole Add Round Effect YTP+++ plugin.'''
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '100'
                type = 'number'
                tooltip = 'Chance that the black-hole round effect is applied.'
            },
            @{
                name = 'Round Count'
                value = '4'
                type = 'number'
                tooltip = 'How many visible add-round beats to create.'
            },
            @{
                name = 'Vortex Strength'
                value = '75'
                type = 'number'
                tooltip = 'Controls swirl, darkening and pull-in intensity.'
            },
            @{
                name = 'Use Item Images'
                value = '1'
                type = 'bool'
                tooltip = 'Pull PNG/JPG characters or objects from the item image library.'
            },
            @{
                name = 'Use Item Clips'
                value = '1'
                type = 'bool'
                tooltip = 'Pull a transparent/green-screen video clip into the black hole.'
            },
            @{
                name = 'Use SFX'
                value = '1'
                type = 'bool'
                tooltip = 'Mix whoosh/suction/pop sounds from the SFX library.'
            },
            @{
                name = 'Item Scale'
                value = '24'
                type = 'number'
                tooltip = 'Item size as a percentage of output width.'
            },
            @{
                name = 'Show Round Text'
                value = '1'
                type = 'bool'
                tooltip = 'Draw ROUND labels like a black-hole add-round project.'
            },
            @{
                name = 'SFX Volume'
                value = '1.2'
                type = 'float'
                tooltip = 'Whoosh/suction sound volume multiplier.'
            },
            @{
                name = 'Black Hole Items'
                value = ''''''
                type = 'image'
                tooltip = 'PNG/JPG characters, props, objects and add-round item cutouts.'
            },
            @{
                name = 'Black Hole Clips'
                value = ''''''
                type = 'video'
                tooltip = 'Short transparent or green-screen object/character clips.'
            },
            @{
                name = 'Black Hole SFX'
                value = ''''''
                type = 'audio'
                tooltip = 'Whooshes, suction sounds, impacts, pops and round transition sounds.'
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
