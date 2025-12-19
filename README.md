# Redmine User Lockout plugin

指定回数ログインに失敗した場合に対象ユーザをロックするプラグインです。

不特定多数のユーザがアクセスできる環境で運用している場合、ユーザアカウントをロックする攻撃に使用することができてしまいます。このプラグインを導入する前にOAuth2や2FAの導入を検討してください。

## Installation

1. Clone or copy files into the Redmine plugins directory
   `git clone https://github.com/taikii/redmine_user_lockout.git`
2. Restart Redmine

## Usage

- ログイン失敗回数はユーザカスタムフィールド（整数型） `Login failed count` で管理します。
- ユーザカスタムフィールドは初めてログイン失敗が発生した際に自動作成されます。
- カスタムフィールドはプラグインの設定画面で変更できます。
- 失敗回数のしきい値はプラグインの設定画面で変更できます。設定した回数を超えた場合に対象ユーザがロックされます。
- しきい値に `0` 以下の数値を設定すると、本処理は実行されません。
- ロックされた際は対象者にメール通知されます。
- ログインに成功すると失敗回数がリセットされます。
- ユーザの `Login failed count` に `-1` など `0` より小さい値を設定すると、本処理の対象外となります。

## License

This plugin is released under the MIT License.
