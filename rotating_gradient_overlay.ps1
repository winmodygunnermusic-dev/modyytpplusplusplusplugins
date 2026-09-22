# YTP+++ PowerShell plugin: Rotating Gradient Overlay
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Rotating Gradient Overlay'
        description = 'Adds a continuously rotating colored gradient overlay.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Rotating Gradient Overlay'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Adds a continuously rotating colored gradient overlay.'
                type = 'label'
            },
            @{
                name = 'Opacity'
                value = '45'
                type = 'int'
                tooltip = 'Strength of the gradient overlay.'
            },
            @{
                name = 'Rotation Speed'
                value = '90'
                type = 'int'
                tooltip = 'How quickly the gradient rotates.'
            },
            @{
                name = 'Gradient Width'
                value = '1.0'
                type = 'float'
                tooltip = 'Width of the gradient transition.'
            },
            @{
                name = 'Color 1'
                value = 'FF00FF'
                type = 'string'
                tooltip = 'First gradient color in hexadecimal RGB format.'
            },
            @{
                name = 'Color 2'
                value = '00FFFF'
                type = 'string'
                tooltip = 'Second gradient color in hexadecimal RGB format.'
            }
        )
    }
}
