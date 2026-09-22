# YTP+++ PowerShell plugin: Everyone Screams Runs From Dot
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Everyone Screams Runs From Dot'
        description = 'Everyone Screams Runs From Dot YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'EFFECT_NAME'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'DESCRIPTION'
                type = 'label'
            },
            @{
                name = 'Overlay Chance'
                value = '75'
                type = 'int'
                tooltip = 'Chance that the running overlay is used.'
            },
            @{
                name = 'Scream Chance'
                value = '85'
                type = 'int'
                tooltip = 'Chance that a scream sound is added.'
            },
            @{
                name = 'Overlay Scale'
                value = '100'
                type = 'int'
                tooltip = 'Size of the green-screen character.'
            },
            @{
                name = 'Overlay Position'
                value = '1'
                type = 'bool'
                tooltip = 'Randomize the overlay position.'
            },
            @{
                name = 'Scream Volume'
                value = '1.25'
                type = 'float'
                tooltip = 'Volume of the screaming sound.'
            },
            @{
                name = 'Dot Panic'
                value = '1'
                type = 'bool'
                tooltip = 'Makes the overlay appear larger and more chaotic.'
            },
            @{
                name = 'Running Overlays'
                value = ''''''
                type = 'video'
                tooltip = 'Green-screen people, animals, or characters running away.'
            },
            @{
                name = 'Screaming'
                value = ''''''
                type = 'audio'
                tooltip = 'Screams, shouting, panic noises, and running-away sounds.'
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
