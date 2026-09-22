# YTP+++ PowerShell plugin: Arabfunny Gen Alpha
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Arabfunny Gen Alpha'
        description = 'Arabfunny Gen Alpha YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Arabfunny Gen Alpha'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Arabfunny Gen Alpha YTP+++ plugin.'''
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '65'
                type = 'number'
                tooltip = 'Chance that the ArabFunny / Gen Alpha effect runs.'
            },
            @{
                name = 'Chaos Level'
                value = '70'
                type = 'number'
                tooltip = 'Controls speed changes, color distortion, shake and loudness.'
            },
            @{
                name = 'Use Videos'
                value = '1'
                type = 'bool'
                tooltip = 'Randomly cuts to a meme video from the ArabFunny Videos library.'
            },
            @{
                name = 'Use Audio'
                value = '1'
                type = 'bool'
                tooltip = 'Mixes a random sound from the ArabFunny Audio library.'
            },
            @{
                name = 'Use Images'
                value = '1'
                type = 'bool'
                tooltip = 'Overlays a random image from the ArabFunny Images library.'
            },
            @{
                name = 'Use Overlays'
                value = '1'
                type = 'bool'
                tooltip = 'Overlays a random transparent/green-screen video from the ArabFunny Overlays library.'
            },
            @{
                name = 'Overlay Scale'
                value = '45'
                type = 'number'
                tooltip = 'Overlay/image size as a percentage of the output width.'
            },
            @{
                name = 'Audio Volume'
                value = '1.4'
                type = 'float'
                tooltip = 'Injected audio volume multiplier.'
            },
            @{
                name = 'ArabFunny Videos'
                value = ''''''
                type = 'video'
                tooltip = 'Short ArabFunny / Gen Alpha meme video clips.'
            },
            @{
                name = 'ArabFunny Audio'
                value = ''''''
                type = 'audio'
                tooltip = 'Arabic meme sounds, Gen Alpha SFX, distorted music and reactions.'
            },
            @{
                name = 'ArabFunny Images'
                value = ''''''
                type = 'image'
                tooltip = 'PNG/JPG meme images, captions, emoji and reaction stills.'
            },
            @{
                name = 'ArabFunny Overlays'
                value = ''''''
                type = 'video'
                tooltip = 'Transparent or green-screen video overlays.'
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
