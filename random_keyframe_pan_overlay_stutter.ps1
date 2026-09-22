# YTP+++ PowerShell plugin: Random Keyframe Pan Overlay Stutter
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Random Keyframe Pan Overlay Stutter'
        description = 'Random Keyframe Pan Overlay Stutter YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Random Keyframe Pan Overlay Stutter'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Random Keyframe Pan Overlay Stutter YTP+++ plugin.'''
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '100'
                type = 'number'
                tooltip = 'Chance that this effect runs.'
            },
            @{
                name = 'Motion Amount'
                value = '70'
                type = 'number'
                tooltip = 'Strength of random keyframed pan and crop motion.'
            },
            @{
                name = 'Snap Amount'
                value = '65'
                type = 'number'
                tooltip = 'Strength of snapping zoom cuts and hard keyframe jumps.'
            },
            @{
                name = 'Stutter Amount'
                value = '45'
                type = 'number'
                tooltip = 'How aggressively frames are repeated for stutter edits.'
            },
            @{
                name = 'Use Overlay Images'
                value = '1'
                type = 'bool'
                tooltip = 'Layer random images from the overlay image library.'
            },
            @{
                name = 'Overlay Count'
                value = '3'
                type = 'number'
                tooltip = 'How many random image layers to place over the video.'
            },
            @{
                name = 'Use Loud Audio Hits'
                value = '1'
                type = 'bool'
                tooltip = 'Mix loud audio hits in sync with snap/stutter moments.'
            },
            @{
                name = 'Audio Loudness'
                value = '1.8'
                type = 'float'
                tooltip = 'Volume multiplier for synchronized hit sounds.'
            },
            @{
                name = 'Keyframe Overlays'
                value = ''''''
                type = 'image'
                tooltip = 'PNG/JPG stickers, captions, emojis and overlay images.'
            },
            @{
                name = 'Keyframe Hits'
                value = ''''''
                type = 'audio'
                tooltip = 'Whooshes, impacts, bass hits and loud sync sounds.'
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
