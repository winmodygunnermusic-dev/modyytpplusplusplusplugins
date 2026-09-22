# YTP+++ PowerShell plugin: Mlg 2012 Meme Effect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Mlg 2012 Meme Effect'
        description = 'Mlg 2012 Meme Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Mlg 2012 Meme Effect'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Mlg 2012 Meme Effect YTP+++ plugin.'''
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '80'
                type = 'number'
                tooltip = 'Chance that the MLG meme edit is applied.'
            },
            @{
                name = 'Meme Intensity'
                value = '85'
                type = 'number'
                tooltip = 'Controls deep-fry strength, flashing, shake and overlay chaos.'
            },
            @{
                name = 'Airhorn Audio'
                value = '1'
                type = 'bool'
                tooltip = 'Mix a random loud meme SFX from the MLG SFX library.'
            },
            @{
                name = 'Image Spam'
                value = '1'
                type = 'bool'
                tooltip = 'Overlay a random meme PNG/JPG from the MLG Images library.'
            },
            @{
                name = 'Video Overlay'
                value = '1'
                type = 'bool'
                tooltip = 'Overlay a random transparent/green-screen meme clip.'
            },
            @{
                name = 'Text Overlay'
                value = '1'
                type = 'bool'
                tooltip = 'Draw oversized MLG parody text on top of the video.'
            },
            @{
                name = 'Overlay Scale'
                value = '45'
                type = 'number'
                tooltip = 'Image/video overlay size as a percent of output width.'
            },
            @{
                name = 'SFX Volume'
                value = '1.7'
                type = 'float'
                tooltip = 'Injected airhorn/SFX volume multiplier.'
            },
            @{
                name = 'Caption Text'
                value = ''
                type = 'string'
                tooltip = 'Optional fixed caption. Leave blank for a random MLG phrase.'
            },
            @{
                name = 'MLG SFX'
                value = ''''''
                type = 'audio'
                tooltip = 'Airhorns, hitmarkers, bass drops, explosions and reaction sounds.'
            },
            @{
                name = 'MLG Images'
                value = ''''''
                type = 'image'
                tooltip = 'Transparent meme PNGs/JPGs such as glasses, hitmarkers and logos.'
            },
            @{
                name = 'MLG Overlays'
                value = ''''''
                type = 'video'
                tooltip = 'Short transparent or green-screen MLG-style video overlays.'
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
