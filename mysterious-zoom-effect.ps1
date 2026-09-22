# YTP+++ PowerShell plugin: Mysterious Zoom Effect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Mysterious Zoom Effect'
        description = 'YTP-style NVG pixel effect with safe default parameters.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Mysterious Zoom Effect'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'YTP-style NVG pixel effect with safe default parameters.'
                type = 'label'
            },
            @{
                name = 'zoom'
                value = 0.5
                type = 'number'
            },
            @{
                name = 'centerX'
                value = 0.5
                type = 'number'
            },
            @{
                name = 'centerY'
                value = 0.5
                type = 'number'
            }
        )
    }
}

function run {
    param($state)

    if ($null -eq $state) {
        return $null
    }

    return @($state.r, $state.g, $state.b)
}
