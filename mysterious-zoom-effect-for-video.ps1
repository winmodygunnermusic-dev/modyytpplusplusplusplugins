# YTP+++ PowerShell plugin: Mysterious Zoom Effect For Video
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Mysterious Zoom Effect For Video'
        description = 'YTP-style NVG pixel effect with safe default parameters.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Mysterious Zoom Effect For Video'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'YTP-style NVG pixel effect with safe default parameters.'
                type = 'label'
            },
            @{
                name = 'amount'
                value = 0.1
                type = 'number'
            },
            @{
                name = 'speed'
                value = 1.0
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
