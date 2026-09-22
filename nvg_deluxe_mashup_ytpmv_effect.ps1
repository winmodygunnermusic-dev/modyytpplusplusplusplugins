# YTP+++ PowerShell plugin: Nvg Deluxe Mashup Ytpmv Effect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Nvg Deluxe Mashup Ytpmv Effect'
        description = 'Nvg Deluxe Mashup Ytpmv Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Nvg Deluxe Mashup Ytpmv Effect'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Nvg Deluxe Mashup Ytpmv Effect YTP+++ plugin.'''
                type = 'label'
            },
            @{
                name = 'Chance Roll'
                value = '100'
                type = 'number'
                tooltip = 'Chance that the deluxe effect runs.'
            },
            @{
                name = 'Chaos'
                value = '80'
                type = 'number'
                tooltip = 'Overall rainbow, mirror, chop and overlay intensity.'
            },
            @{
                name = 'YTPMV Tempo'
                value = '1.25'
                type = 'float'
                tooltip = 'Speed-loop boost / YTPMV tempo multiplier.'
            },
            @{
                name = 'Frame Reduction'
                value = '18'
                type = 'number'
                tooltip = 'Output FPS for choppy silly edits.'
            },
            @{
                name = 'Overlay Count'
                value = '3'
                type = 'number'
                tooltip = 'Random image overlays/sources to layer.'
            },
            @{
                name = 'Caption Text'
                value = 'NVG DELUXE YTPMV'
                type = 'string'
                tooltip = 'Flashing caption text drawn over the generated remix.'
            },
            @{
                name = 'Use Screen Clip'
                value = '1'
                type = 'bool'
                tooltip = 'Blend in a random screen clip/source video.'
            },
            @{
                name = 'Use SpaDinner Audio'
                value = '1'
                type = 'bool'
                tooltip = 'Mix SpaDinner-style hits and silly audio.'
            },
            @{
                name = 'Use Sentence Mix'
                value = '1'
                type = 'bool'
                tooltip = 'Mix short sentence/audio chops as accents.'
            },
            @{
                name = 'Generate Vegas Metadata'
                value = '1'
                type = 'bool'
                tooltip = 'Write a simple keyframe instruction sidecar next to the output.'
            },
            @{
                name = 'Deluxe Overlay Images'
                value = ''''''
                type = 'image'
                tooltip = 'PNG/JPG stickers, captions, source images and silly overlays.'
            },
            @{
                name = 'Deluxe Screen Clips'
                value = ''''''
                type = 'video'
                tooltip = 'Source clips, screen captures and mashup video layers.'
            },
            @{
                name = 'SpaDinner Audio'
                value = ''''''
                type = 'audio'
                tooltip = 'SpaDinner SFX, bleeps, boings, screams and loud hits.'
            },
            @{
                name = 'Sentence Mix Audio'
                value = ''''''
                type = 'audio'
                tooltip = 'Short words, phrases and chopped audio for sentence-mix accents.'
            },
            @{
                name = 'YTPMV Audio Hits'
                value = ''''''
                type = 'audio'
                tooltip = 'Shared YTPMV hits for deluxe musical accents.'
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
