# Presentation design document

## Terms

|用語|意味|
|-|-|
|依存する|あるオブジェクトが自身の責務を果たすために別のオブジェクトを利用すること|
|通知する|あるオブジェクトが別のオブジェクトへ情報の更新を知らせること|
|調整する|あるオブジェクトが依存する複数のオブジェクトをまとめ上げて責務を果たすこと|

## View Model

View ModelはひとつのPageへ通知する。
また、それ以外のPageから依存されることはない。

View Modelはひとつ以上のStateを調整する。
ひとつのStateは複数のViewModelに依存されることがある。

View Modelはひとつ以上のUseCaseまたはRepositoryに依存する。
UseCaseまたはRepositoryはひとつ以上のView Modelに依存されることがある。
