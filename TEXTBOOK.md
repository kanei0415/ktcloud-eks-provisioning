# EKS + Fargate + Terraform + Ansible + ArgoCD 入門テキストブック

**副題: ktcloud-eks-provisioning プロジェクトのプロビジョニング結果レポート**

本書は、本リポジトリ `ktcloud-eks-provisioning` で実際に構築した
AWS EKS クラスタ（ハイブリッド構成: Fargate + マネージドノードグループ）と、
その上で動作する ArgoCD ブートストラップの**プロビジョニング結果レポート**を、
EKS や AWS に不慣れな読者のための**入門テキストブック**として書き起こしたものです。

---

## 目次

### 第 I 部 概論
- 第 1 章 [本書について](#第-1-章-本書について)
- 第 2 章 [このプロジェクトで作ったものの全体像](#第-2-章-このプロジェクトで作ったものの全体像)
- 第 3 章 [Kubernetes と AWS EKS の位置づけ](#第-3-章-kubernetes-と-aws-eks-の位置づけ)

### 第 II 部 ネットワーク
- 第 4 章 [VPC とサブネット](#第-4-章-vpc-とサブネット)
- 第 5 章 [ルートテーブル、IGW、NAT ゲートウェイ](#第-5-章-ルートテーブルigwnat-ゲートウェイ)
- 第 6 章 [サブネットの CIDR 設計](#第-6-章-サブネットの-cidr-設計)
- 第 7 章 [EKS のためのサブネットタグ](#第-7-章-eks-のためのサブネットタグ)
- 第 8 章 [セキュリティグループとネットワーク ACL](#第-8-章-セキュリティグループとネットワーク-acl)

### 第 III 部 コンピューティング（仮想マシンとサーバーレス）
- 第 9 章 [EC2 と AMI の基礎](#第-9-章-ec2-と-ami-の基礎)
- 第 10 章 [マネージドノードグループ](#第-10-章-マネージドノードグループ)
- 第 11 章 [AWS Fargate とは何か](#第-11-章-aws-fargate-とは何か)
- 第 12 章 [なぜハイブリッド構成にしたか](#第-12-章-なぜハイブリッド構成にしたか)

### 第 IV 部 ストレージ
- 第 13 章 [EBS と EFS の違い](#第-13-章-ebs-と-efs-の違い)
- 第 14 章 [PersistentVolume と PersistentVolumeClaim](#第-14-章-persistentvolume-と-persistentvolumeclaim)
- 第 15 章 [StorageClass と動的プロビジョニング](#第-15-章-storageclass-と動的プロビジョニング)
- 第 16 章 [EBS CSI ドライバーと IRSA](#第-16-章-ebs-csi-ドライバーと-irsa)
- 第 17 章 [gp2、gp3、ebs-sc の命名問題](#第-17-章-gp2gp3ebs-sc-の命名問題)

### 第 V 部 EKS コントロールプレーン
- 第 18 章 [EKS アーキテクチャ概要](#第-18-章-eks-アーキテクチャ概要)
- 第 19 章 [OIDC プロバイダと IRSA](#第-19-章-oidc-プロバイダと-irsa)
- 第 20 章 [EKS マネージドアドオン](#第-20-章-eks-マネージドアドオン)
- 第 21 章 [Fargate プロファイル](#第-21-章-fargate-プロファイル)

### 第 VI 部 Terraform
- 第 22 章 [IaC と Terraform の基本](#第-22-章-iac-と-terraform-の基本)
- 第 23 章 [HCL 構文の基礎](#第-23-章-hcl-構文の基礎)
- 第 24 章 [プロバイダとバックエンド](#第-24-章-プロバイダとバックエンド)
- 第 25 章 [モジュールと再利用](#第-25-章-モジュールと再利用)
- 第 26 章 [本プロジェクトの Terraform コード解読](#第-26-章-本プロジェクトの-terraform-コード解読)

### 第 VII 部 Ansible
- 第 27 章 [Ansible の基本概念](#第-27-章-ansible-の基本概念)
- 第 28 章 [インベントリ、プレイブック、タスク](#第-28-章-インベントリプレイブックタスク)
- 第 29 章 [モジュールと冪等性](#第-29-章-モジュールと冪等性)
- 第 30 章 [本プロジェクトの Ansible コード解読](#第-30-章-本プロジェクトの-ansible-コード解読)

### 第 VIII 部 ArgoCD と GitOps
- 第 31 章 [GitOps の考え方](#第-31-章-gitops-の考え方)
- 第 32 章 [Application と ApplicationSet](#第-32-章-application-と-applicationset)
- 第 33 章 [App-of-Apps パターン](#第-33-章-app-of-apps-パターン)
- 第 34 章 [本プロジェクトの ArgoCD セットアップ](#第-34-章-本プロジェクトの-argocd-セットアップ)

### 第 IX 部 実際に発生したトラブルとその解決
- 第 35 章 [community.general.yaml コールバック削除](#第-35-章-communitygeneralyaml-コールバック削除)
- 第 36 章 [Helm 4 と kubernetes.core の互換問題](#第-36-章-helm-4-と-kubernetescore-の互換問題)
- 第 37 章 [macOS の BSD tar と unarchive モジュール](#第-37-章-macos-の-bsd-tar-と-unarchive-モジュール)
- 第 38 章 [ArgoCD Helm values の global: null 問題](#第-38-章-argocd-helm-values-の-global-null-問題)
- 第 39 章 [argocd-repo-server の OOMKilled と Bitnami](#第-39-章-argocd-repo-server-の-oomkilled-と-bitnami)
- 第 40 章 [ebs-sc StorageClass 欠落](#第-40-章-ebs-sc-storageclass-欠落)
- 第 41 章 [残課題: Kafka の nfs-client](#第-41-章-残課題-kafka-の-nfs-client)

### 第 X 部 付録
- 第 42 章 [用語集](#第-42-章-用語集)
- 第 43 章 [よく使うコマンドチートシート](#第-43-章-よく使うコマンドチートシート)
- 第 44 章 [学習ロードマップ](#第-44-章-学習ロードマップ)

---

# 第 I 部 概論

## 第 1 章 本書について

### 1.1 想定読者

本書は次のような方を想定しています。

- プログラミングの経験はあるが、AWS や Kubernetes はほとんど触ったことがない。
- 「VPC」「サブネット」「NAT」「Fargate」「StorageClass」といった単語を聞いたことはあるが、
  実際の繋がりが見えていない。
- 自分で `terraform apply` や `ansible-playbook` を打つ場面に出くわしたが、
  各ファイルが何を意味しているのか自信が持てない。
- すでにこのリポジトリ `ktcloud-eks-provisioning` のコードを眺めているが、
  「全体としてどう動いているのか」が掴みきれない。

つまり、本書は**「実物のコードに沿った AWS EKS 入門書」**です。
机上の説明だけでなく、本リポジトリで実際に作られたリソース・実際に発生したエラーを
題材に解説していきます。

### 1.2 本書の進め方

- まず**全体像**（第 2〜3 章）を掴みます。地図を持ってから森に入ります。
- 次に**ネットワーク → コンピュート → ストレージ → コントロールプレーン**の順で
  AWS 側のレイヤを下から積み上げます。
- そのうえで **Terraform → Ansible → ArgoCD** と、コードでそれらをどう操っているかを見ます。
- 最後に**実際に踏んだトラブル**を 1 つずつ振り返ります。これは「やってみると必ず引っかかる」
  落とし穴集でもあり、現場で最も学習効率の高いセクションです。

### 1.3 表記ルール

- コード片はバッククォート三つで囲まれたブロックで示します。
- ファイルパスは `terraform/eks.tf` のように相対パスで示します。
- AWS リソース名は固有名詞として英字のまま、概念は和訳併記（例: VPC（仮想プライベートクラウド））。
- 「**A** = B」という表記は「A とは B のこと」という定義を意味します。

---

## 第 2 章 このプロジェクトで作ったものの全体像

### 2.1 一枚絵

```
┌─────────────────────────────────────────────────────────────────┐
│  AWS アカウント 208876571165 / リージョン ap-northeast-2 (Seoul) │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  VPC 10.40.0.0/16  (terraform-aws-modules/vpc が作成)   │   │
│  │                                                         │   │
│  │   ┌──── public subnet × 3 AZ ────┐  ← Internet Gateway  │   │
│  │   │ 10.40.128/20, .144/20, .160  │                      │   │
│  │   └──────────────┬───────────────┘                      │   │
│  │                  │ NAT GW                               │   │
│  │   ┌──── private subnet × 3 AZ ───┐                      │   │
│  │   │ 10.40.0/20, .16/20, .32/20   │                      │   │
│  │   └──────────────┬───────────────┘                      │   │
│  │                  │                                      │   │
│  │     ┌────────────┴──────────────┐                       │   │
│  │     ▼                           ▼                       │   │
│  │  ┌─────────────┐         ┌───────────────────────────┐  │   │
│  │  │ Fargate     │         │ Managed Node Group        │  │   │
│  │  │ (kube-system│         │ workloads / t3.medium × 2 │  │   │
│  │  │ , argocd)   │         │ (Postgres, Kafka, Redis,  │  │   │
│  │  │             │         │  Traefik, KTCloudMarket)  │  │   │
│  │  └─────────────┘         └───────────────────────────┘  │   │
│  │                                                         │   │
│  │              EKS Control Plane (AWS 管理)               │   │
│  │              kube-api / etcd / scheduler                │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ▲
                              │ kubectl / Helm / ArgoCD
                              │
       ┌──────────────────────┴────────────────────────┐
       │   ローカルマシン (macOS)                      │
       │   ├ Terraform → AWS API へリソース作成        │
       │   └ Ansible    → クラスタ API へ Helm/kubectl │
       └───────────────────────────────────────────────┘
```

### 2.2 役割分担

- **Terraform** はインフラ（VPC、EKS、ノードグループ、IAM、CSI 等）を作る役。
- **Ansible** はクラスタの中身（ArgoCD のインストールと root-app の適用）を作る役。
- **ArgoCD** はそこから先のアプリケーション一式を、別リポジトリ
  `kanei0415/ktcloud-k8s-argocd-manifest` から継続的に同期する役。

この三段ロケットの境界線をはっきり覚えておくと、トラブル時に
「これは Terraform で直す問題か、Ansible で直す問題か、ArgoCD（つまりマニフェストリポ）
で直す問題か」を判断しやすくなります。

### 2.3 デプロイ後にクラスタに存在するもの

実行が完了すると、おおよそ以下が動いている状態になります。

| ネームスペース | 主な Pod | 配置先 |
| --- | --- | --- |
| `kube-system` | coredns、aws-node、kube-proxy、ebs-csi-controller | Fargate と Node Group の混在 |
| `argocd` | argocd-server、argocd-repo-server、application-controller、redis、applicationset-controller | Fargate |
| `postgresql` | Bitnami postgresql | Node Group |
| `redis` | Bitnami redis | Node Group |
| `kafka` | Strimzi operator + Kafka cluster | Node Group |
| `traefik` | Traefik proxy | Node Group |
| `ktcloud-market-msa` | 5 サービス (auth/inventory/order/product/gateway) | Node Group |

「Fargate と Node Group の混在」というのは、CoreDNS のように設定上 Fargate に流せるものは
Fargate へ、DaemonSet（aws-node、kube-proxy）のように Fargate で動かない種類は Node Group へ、
という自動的な振り分けの結果です。詳しくは第 12 章で説明します。

---

## 第 3 章 Kubernetes と AWS EKS の位置づけ

### 3.1 Kubernetes (k8s) は何をするものか

Kubernetes は**コンテナのオーケストレーター**です。
「コンテナ（Docker などで作ったアプリの実行単位）を、複数台のマシンの上に良い感じに
配ったり、落ちたら再起動したり、ネットワーク・ストレージを繋いだりする」役割を担います。

主要な登場人物：

- **Pod** — コンテナを 1 つ以上まとめた実行単位。k8s が直接管理する最小単位。
- **Deployment / StatefulSet / DaemonSet** — Pod の作り方の設計図。
  - Deployment は普通のアプリ用。
  - StatefulSet は順序や永続ボリュームが必要なもの（DB など）用。
  - DaemonSet は「全ノードに 1 つずつ」走らせるもの（ログ転送、ネットワークプラグインなど）。
- **Service** — Pod 群への安定したエンドポイント（クラスタ内 DNS と仮想 IP）。
- **Ingress / Gateway** — クラスタ外からの HTTP/HTTPS をルーティングする入口。
- **Namespace** — リソースの論理的な仕切り。本プロジェクトでは `argocd`、`postgresql` などに分けています。

### 3.2 EKS (Elastic Kubernetes Service) とは

EKS は AWS が提供する**マネージド Kubernetes サービス**です。
Kubernetes のコントロールプレーン（API サーバー、etcd、スケジューラ、コントローラーマネージャー）を
AWS が運用してくれます。利用者は**データプレーン（ノード）の準備とアプリケーションのデプロイ**に集中できます。

EKS を使うか、素の Kubernetes を自前で建てるかの比較：

| 項目 | EKS | 自前 k8s |
| --- | --- | --- |
| コントロールプレーンの運用 | AWS | 自分 |
| etcd のバックアップ | AWS | 自分 |
| 高可用構成 | デフォルトで複数 AZ | 自分で設計 |
| バージョンアップ | API 1 コマンド | 手動 |
| 価格 | クラスタ毎 $0.10/h + ノード代 | ノード代のみ |

新規プロジェクトで「Kubernetes 本体の運用までやりたくない」場合、ほぼ EKS 一択です。

### 3.3 EKS Fargate とは

EKS には 2 つのデータプレーン選択肢があります。

1. **マネージドノードグループ (EC2)** — EC2 仮想マシンが Kubernetes ノードとして参加します。OS が見えます。
2. **Fargate** — VM が見えません。Pod を要求すると、AWS が裏で 1 Pod = 1 マイクロ VM を起動して
   Kubernetes ノードのフリをさせます。OS の管理は完全に AWS の責任です。

本プロジェクトはこの両方を併用しています（理由は第 12 章）。

---

# 第 II 部 ネットワーク

## 第 4 章 VPC とサブネット

### 4.1 VPC は「AWS 内の自分専用のネットワーク」

VPC（Virtual Private Cloud）は、ひとつの AWS アカウントの中に切り出された
**論理的に隔離された IP ネットワーク**です。VPC ごとに自由な IP レンジ（CIDR）を選べ、
他の VPC や他人のリソースとは（明示的に接続しない限り）一切通信できません。

本プロジェクトでは VPC のレンジを **`10.40.0.0/16`** にしています。
これは「10.40.0.0 から 10.40.255.255 まで」、つまり 65,536 個の IP を持つ広い空間です。

```
10.40.0.0/16 = 10.40.000.000 〜 10.40.255.255
              └───────── 65,536 個 ─────────┘
```

なぜ `10.0.0.0/16` ではなく `10.40.0.0/16` を選んだのか？　将来別の VPC や VPN と
ピアリング（接続）するときに、IP レンジが衝突しないようにするためです。
`10.0.0.0/16` や `192.168.0.0/16` は他のシステムでも使われがちなので意図的に避けています。

### 4.2 サブネットは「VPC をさらに切り分けたもの」

サブネット（subnet）は VPC の中をさらに細かく分けた区画で、**必ず 1 つのアベイラビリティゾーン (AZ)
に属します**。AZ は同じリージョン内の独立した（物理的に離れた）データセンター群です。
東京リージョンなら `ap-northeast-1a`, `1c`, `1d`、ソウルなら `ap-northeast-2a`, `2b`, `2c` という具合に。

EKS は**最低 2 つの AZ**にサブネットを持つことを要求します。本プロジェクトでは
高可用性のために 3 AZ に分散させています。

サブネットには 2 種類があります：

- **パブリックサブネット** — インターネットに直接出入りできる。
  Internet Gateway を経由する経路を持つ。ロードバランサや踏み台などが置かれます。
- **プライベートサブネット** — インターネットへの**出口**だけ持つ（NAT 経由）。**入口**は持たない。
  EKS ノードや Fargate Pod、DB 等の「直接外から触られたくないもの」を置きます。

```
インターネット
    │
    ├──────────►  Internet Gateway
    │             │
    │  パブリック  │   ┌─ 10.40.128.0/20 (ap-northeast-2a)
    │  サブネット  ├──►├─ 10.40.144.0/20 (ap-northeast-2b)
    │             │   └─ 10.40.160.0/20 (ap-northeast-2c)
    │             │           │
    │             │           │ NAT Gateway (1 個だけ)
    │             ▼           ▼
    │  プライベート     ┌─ 10.40.0.0/20  (ap-northeast-2a)
    │  サブネット   ◄──┤   10.40.16.0/20 (ap-northeast-2b)
    │                  └─ 10.40.32.0/20 (ap-northeast-2c)
```

本プロジェクトでは**ノードと Fargate Pod の両方をプライベートサブネットに配置**しています。
理由は単純で、不必要に外から直接到達できるリソースを増やさないためです。
インターネット公開が必要なものは将来的に「LB をパブリック、Pod はプライベート」という
構成にします（AWS Load Balancer Controller を入れたあとの話）。

---

## 第 5 章 ルートテーブル、IGW、NAT ゲートウェイ

### 5.1 ルートテーブル

ルートテーブルは「**この CIDR への通信は、こっちへ送れ**」というルールの集まりです。
1 つのサブネットには 1 つのルートテーブルが紐付きます。

パブリックサブネットのルートテーブル（簡略）：
```
宛先              ターゲット
10.40.0.0/16  →  local (VPC 内)
0.0.0.0/0    →   Internet Gateway (IGW)
```

プライベートサブネットのルートテーブル（簡略）：
```
宛先              ターゲット
10.40.0.0/16  →  local
0.0.0.0/0    →   NAT Gateway
```

つまり「**VPC 内宛は VPC 内、それ以外はインターネット側へ**」というルールです。
パブリックは IGW を、プライベートは NAT を通る、これがパブリック／プライベートの本質です。

### 5.2 Internet Gateway (IGW)

IGW は VPC とインターネットを繋ぐ**双方向**のゲート。
パブリックサブネット内のリソースが Elastic IP（または自動割当てパブリック IP）を持っていれば、
IGW 経由で「インターネット → VPC」「VPC → インターネット」のどちらの方向の通信もできます。

### 5.3 NAT Gateway

NAT Gateway は、**プライベートサブネットからインターネット（外）へ出る**ためだけのゲートです。
逆向き（インターネット → プライベートサブネット）の通信は通せません。
Pod が `apt update` したり、コンテナイメージを引っ張ってきたり、AWS API を叩いたりするのに使われます。

本プロジェクトでは **NAT Gateway を 1 個**しか作っていません（`single_nat_gateway = true`）。

```hcl
# terraform/vpc.tf
enable_nat_gateway   = true
single_nat_gateway   = true
```

これは**コスト最適化**です。NAT Gateway は 1 個あたり時間課金（東京で月 $30〜 程度）＋ データ転送課金
がかかります。本来は AZ ごとに 1 個ずつ作って AZ 障害に強くするのが定石ですが、
学習・開発用クラスタでは 1 個で十分です。本番運用では `single_nat_gateway = false` にしましょう。

---

## 第 6 章 サブネットの CIDR 設計

### 6.1 cidrsubnet 関数で機械的に分割する

本プロジェクトの `terraform/locals.tf` には次のコードがあります：

```hcl
locals {
  private_subnets = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 4, i + 8)]
}
```

`cidrsubnet(prefix, newbits, netnum)` は Terraform 組み込み関数で、
「`prefix` を `newbits` ビット細分化したうちの `netnum` 番目」を返します。

- `var.vpc_cidr = "10.40.0.0/16"`、`newbits = 4` なので、`/16 + 4 = /20` のサブネットができます。
- `/20` は IP が 4,096 個。EKS ノード・Pod・Fargate を載せるには十分（Pod 1 つあたり 1 IP 消費する点に注意）。
- `i = 0,1,2` で `/20` の 0, 1, 2 番目（プライベート用）。
- `i + 8 = 8,9,10` で 8, 9, 10 番目（パブリック用）。

結果：
```
private[0] = 10.40.0.0/20     # 10.40.0.0   〜 10.40.15.255
private[1] = 10.40.16.0/20    # 10.40.16.0  〜 10.40.31.255
private[2] = 10.40.32.0/20    # 10.40.32.0  〜 10.40.47.255
public[0]  = 10.40.128.0/20   # 10.40.128.0 〜 10.40.143.255
public[1]  = 10.40.144.0/20   # 10.40.144.0 〜 10.40.159.255
public[2]  = 10.40.160.0/20   # 10.40.160.0 〜 10.40.175.255
```

途中の `/20` 域（番号 3〜7）を空けてある理由は、後から別用途のサブネット（DB 専用、踏み台専用など）を
入れるときに番号が衝突しないようにという「のりしろ」です。

### 6.2 IP 数の現実

EKS の **VPC CNI** プラグイン（Pod に VPC の IP を直接割り当てる仕組み）の都合上、
Pod の数 ≒ 使う IP の数になります。例えば 100 Pod 動かすクラスタなら最低でも 100 個の Pod IP +
ノード IP + LB IP 等を見越したサブネットサイズが必要です。`/20` の 4,096 個があれば、
3 AZ 合わせて 12,288 IP あるので開発・小規模本番では十分すぎるくらいです。

---

## 第 7 章 EKS のためのサブネットタグ

### 7.1 タグでロールバランサに「ここを使え」と教える

EKS のサブネットには、AWS Load Balancer Controller などが認識する**お約束のタグ**を
付けます。本プロジェクトでは `terraform/vpc.tf` で次のように書いています：

```hcl
public_subnet_tags = {
  "kubernetes.io/role/elb"                      = "1"
  "kubernetes.io/cluster/${local.cluster_name}" = "shared"
}

private_subnet_tags = {
  "kubernetes.io/role/internal-elb"             = "1"
  "kubernetes.io/cluster/${local.cluster_name}" = "shared"
}
```

意味：

- `kubernetes.io/role/elb = 1` — パブリックロードバランサ（インターネット向け）はここに作って良い。
- `kubernetes.io/role/internal-elb = 1` — 内部ロードバランサはここに作って良い。
- `kubernetes.io/cluster/<クラスタ名> = shared` — このサブネットは指定したクラスタで使われる。
  `shared` は「他のクラスタと共有してもよい」、`owned` は「このクラスタ専用」。

これらのタグは AWS Load Balancer Controller が `Service type=LoadBalancer` や `Ingress` を作るときに
「どのサブネットに ALB/NLB を立てるか」を自動判別する根拠になります。
**タグを付け忘れると、ALB/NLB の自動作成が失敗します**。これは EKS 初心者がよく踏むトラップです。

---

## 第 8 章 セキュリティグループとネットワーク ACL

### 8.1 セキュリティグループはステートフル・ファイアウォール

セキュリティグループ（SG）は AWS のリソース（EC2、ENI、Fargate タスク等）に**直接**紐付く
ファイアウォールです。特徴：

- **ステートフル**。インバウンドで許可した戻りは自動で許可される。
- **デフォルト拒否**。明示的に許可しない限り通らない。
- インバウンドルールとアウトバウンドルールを別々に書く。
- IP 範囲だけでなく、**別の SG を許可元として指定できる**（よくある書き方）。

EKS では `terraform-aws-modules/eks/aws` が次の SG を自動生成します：

1. **クラスタ SG** — コントロールプレーンとノードの間の通信用。
2. **ノード SG** — ノード同士、ノードと Pod、ノードと kubelet/api server 間の通信用。
3. **追加の Pod SG** — IRSA や Security Groups for Pods を使うときに登場。

本プロジェクトでは個別にカスタマイズはしていません。モジュールのデフォルトで十分です。
ただし**「クラスタが構築できたのに Pod が動かない」**ような時には、
SG ルール（インバウンドの 443 ポートや 10250 ポート）を疑うと良いです。

### 8.2 ネットワーク ACL は通常デフォルトで OK

ネットワーク ACL（NACL）はサブネット単位のファイアウォールで、ステートレスです。
ほとんどのケースでデフォルト（全許可）のまま運用します。
SG だけで足りない理由がある場合のみ NACL を細かく書きます。

---

# 第 III 部 コンピューティング（仮想マシンとサーバーレス）

## 第 9 章 EC2 と AMI の基礎

### 9.1 EC2 とは

EC2（Elastic Compute Cloud）は AWS の代名詞である**仮想マシン**サービスです。
インスタンスを起動 → SSH や AWS Systems Manager で繋ぐ → 普通の Linux/Windows として使う、
という流れです。

EC2 の構成要素：

| 要素 | 説明 |
| --- | --- |
| インスタンスタイプ | CPU・メモリ・ネットワークの「型番」。例: `t3.medium` = 2 vCPU, 4 GiB |
| AMI | OS イメージ（テンプレート）。Amazon Linux 2、Ubuntu などの選択肢 |
| EBS ボリューム | インスタンスに繋がるディスク（後述） |
| ENI | 仮想ネットワークインタフェース。プライマリ IP・セカンダリ IP を持つ |
| キーペア | SSH 用の公開鍵。ただし EKS マネージドノードでは不要 |

### 9.2 インスタンスタイプの読み方

`t3.medium` を分解すると：

- `t` — インスタンスファミリ。`t` はバースト型（普段は性能が低めだが、必要時にクレジットを使って瞬発力を出せる）。
- `3` — 世代番号。新しいほど性能・コスト効率が良い傾向。
- `medium` — サイズ。`nano < micro < small < medium < large < xlarge < ...`

本プロジェクトのデフォルトは `t3.medium`（2 vCPU、4 GiB）です。
開発・テスト用のお手頃サイズです。本番ワークロードでは `m5.large`（汎用）や
`c6i.xlarge`（コンピュート向け）など、用途に応じて選びます。

### 9.3 キャパシティタイプ

EC2 の購入形態：

- **オンデマンド (ON_DEMAND)** — いつでも起動・停止できる定価。
- **スポット (SPOT)** — AWS の余剰キャパシティを最大 90% 引きで使えるが、いつでも回収される可能性あり。
- **リザーブド / Savings Plans** — 長期コミットで割引。

本プロジェクトでは `capacity_type = "ON_DEMAND"` を使っています（`terraform/eks.tf`）。
学習用なので潰されないオンデマンドが安心です。

---

## 第 10 章 マネージドノードグループ

### 10.1 ノードグループとは

EKS の**ノードグループ**は、「同じ AMI・同じインスタンスタイプ・同じ IAM ロール」を持つ
EC2 インスタンスの一括管理単位です。

「マネージド」ノードグループは AWS が次のことを代行してくれます：

- AMI の選定（EKS 最適化 AMI を自動）。
- Auto Scaling Group の作成。
- ノードを kubeadm 的に EKS にジョインする処理。
- バージョンアップ時のローリング更新。
- Cordon → Drain → Replace のオーケストレーション。

`terraform/eks.tf` 抜粋：
```hcl
eks_managed_node_groups = {
  workloads = {
    ami_type       = "AL2_x86_64"
    instance_types = var.nodegroup_instance_types  # ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    min_size       = var.nodegroup_min_size      # 2
    max_size       = var.nodegroup_max_size      # 4
    desired_size   = var.nodegroup_desired_size  # 2
    labels = {
      role = "workloads"
    }
  }
}
```

`min/max/desired` は Auto Scaling Group のキャパシティです。
`Cluster Autoscaler` を別途入れない限り `desired` の値で固定されます。
本プロジェクトはまだ Cluster Autoscaler を入れていないので、ノードは常に 2 台です。

### 10.2 ノードの労働内容

ノードは Kubernetes のワーカーです。各ノードでは：

- **kubelet** — コントロールプレーンの命令に従って Pod を起動・停止する。
- **kube-proxy** — Service の仮想 IP を実装する（iptables/IPVS）。
- **CNI（VPC CNI）** — Pod に VPC IP を割り当てる。
- **CSI（EBS CSI ノードプラグイン）** — Pod に EBS ボリュームをマウントする。

が動いています。最初の 3 つは AWS が EKS アドオンとして配布しています。

---

## 第 11 章 AWS Fargate とは何か

### 11.1 「ノードが見えない Kubernetes」

Fargate は、AWS が裏で「**Pod 1 個ごとに**専用のマイクロ VM」を起動して、
Kubernetes には**ノード 1 台に Pod 1 つ**が乗っている形で見せる仕組みです。

利用者から見たメリット：

- EC2 インスタンスの管理（OS パッチ、容量計画）が一切不要。
- 「Pod 1 個に 0.25 vCPU、512 MiB」のような細かい単位で課金される。
- スケジューラがハマることがない（容量がそもそも自動拡張なので）。

デメリットと制約：

- **DaemonSet が動かない**。Fargate は「Pod = ノード」なので、ノードごとに 1 Pod という発想自体が
  ない。
- **EBS が使えない**。EBS は AZ 内の EC2 インスタンスに付くブロックストレージで、Fargate の
  マイクロ VM には付けられない仕様。EFS（NFS）なら使える。
- **GPU 不可**、ホスト ネットワーク不可、特権コンテナ不可。
- **Pod 起動が EC2 より遅い**（30 秒〜数分）。マイクロ VM を毎回プロビジョニングするため。
- **コストは EC2 より高め**になることが多い（小さい Pod を大量に動かすケース除く）。

### 11.2 Fargate プロファイル

Fargate に「どの Pod を流すか」は、**Fargate プロファイル**で宣言します。
プロファイルは「ネームスペースと（任意の）ラベル」で Pod を絞り込みます。

本プロジェクトでは `kube-system` と `argocd` をプロファイル対象にしています：

```hcl
# terraform/eks.tf
fargate_profiles = {
  for ns in var.fargate_namespaces : ns => {
    name = "fp-${ns}"
    selectors = [{ namespace = ns }]
    subnet_ids = module.vpc.private_subnets
  }
}
```

つまり「ネームスペース `kube-system` または `argocd` に作られた Pod は Fargate に行く」
ということです。それ以外のネームスペース（`postgresql`, `kafka`, ...）の Pod は
自動的にマネージドノードグループに着地します。

---

## 第 12 章 なぜハイブリッド構成にしたか

### 12.1 純 Fargate にできない 2 つの理由

理由 1: **DaemonSet が動かない**。
EKS に必要な `aws-node`（VPC CNI）と `kube-proxy` は DaemonSet です。
これらは「全ノードに 1 個ずつ」必要なので、Fargate では成立しません。

→ 純 Fargate にすると、これらは EKS アドオンとして特別な処理が入りますが、
  そもそも DaemonSet を必要とする他のアドオン（ログ転送、メトリクス収集など）も後から入れにくい。

理由 2: **EBS が使えない**。
今回 ArgoCD が同期してくる中身に **Postgres、Kafka、Redis** という StatefulSet があり、
これらは「ブロックストレージにデータを書く」設計です。Fargate では EFS は使えますが、
Postgres を NFS 上で動かすのは性能・整合性面で推奨されません。

### 12.2 ハイブリッド構成のメリット

- ArgoCD と kube-system は Fargate に流して「ノード管理が要らないコントロールプレーン拡張」を実現。
- 重いもの・状態を持つもの（DB、Kafka）はマネージドノードグループに置いて EBS を使う。
- アプリケーション本体（KTCloudMarket の 5 サービス）はノードグループでも Fargate でも動かせるが、
  本プロジェクトでは「`argocd` 以外はノード」というシンプルなルールに統一。

新しいネームスペースを Fargate にしたい場合は、`var.fargate_namespaces` に追加するだけです。

---

# 第 IV 部 ストレージ

## 第 13 章 EBS と EFS の違い

### 13.1 EBS（Elastic Block Store）

EBS は**ブロックストレージ**です。仮想ディスクとして 1 つの EC2 インスタンスに「アタッチ」されます。

特徴：

- **AZ ローカル**。AZ-A の EBS は AZ-B のインスタンスには直接付けられない。
- **1 ボリュームを基本 1 インスタンス**だけが排他的にマウント（IO1/IO2 マルチアタッチ例外あり）。
- 種類: `gp2`（標準汎用、旧世代）、`gp3`（標準汎用、新世代、安くて速い）、`io1/io2`（高 IOPS）、`st1/sc1`（HDD）。
- ファイルシステムは自分でフォーマットして使う（ext4 とか xfs とか）。

データベースや Kafka など「単一プロセスが排他的に書きたい」ワークロードに最適です。

### 13.2 EFS（Elastic File System）

EFS は **NFS ベースのネットワークファイルシステム**です。

特徴：

- **マルチ AZ で共有**。複数の Pod / インスタンスが同時にマウントできる。
- 容量無制限、自動拡張。
- ブロックストレージほど低レイテンシではない（NFS なので）。
- 課金は使用量＋スループット。

「複数 Pod が同じディレクトリに書きたい」「ログを集約したい」「ML の学習データを共有したい」用途に向きます。
ただし**データベースの主データを EFS に置くのは推奨されません**（fsync 周りの NFS の挙動が DB と
相性が悪いことがあるため）。

### 13.3 本プロジェクトでの選択

本プロジェクトは EBS のみを使います。EFS はまだセットアップしていません。
将来 Kafka が `nfs-client` を要求するので EFS が必要になりますが、これは第 41 章で議論します。

---

## 第 14 章 PersistentVolume と PersistentVolumeClaim

### 14.1 二層の抽象

Kubernetes でストレージを使うには 3 つのリソースが登場します。

1. **PersistentVolume (PV)** — クラスタワイドな「実体のあるボリューム」。EBS 1 個に対応する k8s オブジェクト。
2. **PersistentVolumeClaim (PVC)** — Pod から「ボリュームをください」と発注する書類。
3. **StorageClass (SC)** — PVC が来たら「どんな PV を作ればよいか」のテンプレ。

```
[Pod] ─── volumeClaim ───► [PVC] ─── (StorageClass経由でCSIに依頼) ───► [PV] ◄─── 実体（EBS）
```

PVC は「20 GiB を `ReadWriteOnce` で欲しい」のように要求し、
StorageClass の指定があれば、CSI ドライバーが裏で実 EBS を作って PV をバインドしてくれます。
これを **動的プロビジョニング** と呼びます。

### 14.2 アクセスモード

PVC・PV には「どんな繋ぎ方を許すか」を表すアクセスモードがあります：

| モード | 略 | 意味 |
| --- | --- | --- |
| ReadWriteOnce | RWO | 単一ノードから読み書き |
| ReadOnlyMany | ROX | 複数ノードから読み取りのみ |
| ReadWriteMany | RWX | 複数ノードから読み書き |
| ReadWriteOncePod | RWOP | 単一 Pod から読み書き（k8s 1.27+） |

EBS は基本 RWO だけ。EFS は RWX が可能です。Postgres・Redis・Kafka は RWO で十分です。

---

## 第 15 章 StorageClass と動的プロビジョニング

### 15.1 StorageClass の構造

StorageClass の代表的フィールド：

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  fsType: ext4
reclaimPolicy: Delete           # PVC を消したら EBS も消す
volumeBindingMode: WaitForFirstConsumer  # Pod がスケジュールされてからボリューム作る
allowVolumeExpansion: true
```

主要フィールドの意味：

- **provisioner** — どの CSI ドライバーに作成を頼むか。EBS なら `ebs.csi.aws.com`。
- **parameters** — CSI ドライバー固有の引数。EBS なら `type=gp3`, `iops`, `throughput` など。
- **reclaimPolicy** — PVC が削除されたとき、`Delete`（EBS も削除）か `Retain`（残す）。
- **volumeBindingMode** — `Immediate`（PVC 作成時にすぐ EBS 作る）か `WaitForFirstConsumer`
  （Pod が AZ にスケジュールされてから EBS をその AZ に作る）。
  **EBS は AZ ローカル**なので `WaitForFirstConsumer` が推奨。

### 15.2 デフォルト StorageClass

`is-default-class: "true"` を持つ StorageClass がデフォルトになります。
PVC が `storageClassName` を指定しなかった場合、デフォルトが使われます。

**デフォルトは 1 つだけにしてください**。複数あると挙動が未定義になり、PVC がどちらにバインドされるか
わからなくなります。本プロジェクトでは `gp3` をデフォルトにし、EBS CSI アドオンが自動で作る
`gp2` のデフォルトフラグを外しています：

```hcl
# terraform/storage.tf
resource "kubernetes_annotations" "gp2_not_default" {
  ...
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
  force = true
}
```

`force = true` は、`gp2` の StorageClass が **EBS CSI アドオンによってフィールド管理されている**
（つまり Terraform から見ると「他者が変えるかもしれない」状態）ため、
強制的に上書きするためです。

---

## 第 16 章 EBS CSI ドライバーと IRSA

### 16.1 CSI とは

CSI（Container Storage Interface）は「Kubernetes と外部ストレージの間の標準プロトコル」です。
かつては Kubernetes 本体に各種ストレージ用コードが組み込まれていました（in-tree volume plugins）が、
保守不能になり、CSI として外部プラグイン化された経緯があります。

EBS CSI ドライバーは、**Controller Pod** と **Node Pod**（DaemonSet）の 2 種類から成ります：

- Controller — `CreateVolume` / `DeleteVolume` などの「制御面」を担当。EC2 API を叩いて EBS を作る。
- Node — 各ノードで動き、EBS を OS にアタッチしてマウントする。

本プロジェクトでは EKS マネージドアドオンとして導入しています：

```hcl
# terraform/eks.tf
aws-ebs-csi-driver = {
  most_recent              = true
  service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
}
```

### 16.2 IRSA（IAM Roles for Service Accounts）

EBS CSI Controller は EC2 API（`ec2:CreateVolume` 等）を叩く必要があります。
従来は「ノードの IAM ロールにそのポリシーを付ける」雑な方法もありましたが、
ノード上の他の Pod も同じ権限を持ってしまい、最小権限原則に反します。

**IRSA** は、`ServiceAccount` 単位で IAM ロールを引き受けられる仕組みです。
仕組みの概要：

1. EKS クラスタに**OIDC プロバイダ**を有効化する。これでクラスタは自分の ID トークンを発行できる。
2. IAM ロールに「信頼ポリシー」を書き、「この OIDC issuer の特定 SA だけ Assume できる」と定義。
3. Pod に `serviceAccountName` を指定し、ServiceAccount にロール ARN のアノテーションを付ける。
4. AWS SDK は SA トークンをロールに引き換えて、必要な API を叩く。

本プロジェクトでは `ebs_csi_irsa` モジュール（`terraform-aws-modules/iam`）が
IAM ロール + 信頼ポリシー + アタッチを一括で作ってくれています：

```hcl
module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.48"

  role_name             = "${var.project}-ebs-csi-irsa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
```

これで「`kube-system` の `ebs-csi-controller-sa` だけがこのロールを Assume できる」
という最小権限の関係が成立します。

---

## 第 17 章 gp2、gp3、ebs-sc の命名問題

### 17.1 実際に起きたこと

ArgoCD で Postgres / Redis をデプロイしようとすると、PVC が `ProvisioningFailed` で止まりました。
エラー：
```
storageclass.storage.k8s.io "ebs-sc" not found
```

原因の調査結果：

- 本リポジトリで作っている StorageClass は `gp3`（デフォルト）と `gp2`（非デフォルト）のみ。
- マニフェストリポ `kanei0415/ktcloud-k8s-argocd-manifest` の `Addons/Postgresql/values.yaml` と
  `Addons/Redis/values.yaml` は `storageClass: "ebs-sc"` をハードコードしていた。

つまり、PVC 側が要求する名前が、クラスタにある名前と一致していませんでした。

### 17.2 対処の選択肢と判断

- 案 A: **マニフェストリポ側を修正**して `gp3` または空文字（デフォルト）にする。一番きれい。
- 案 B: **インフラ側に `ebs-sc` という別名の StorageClass を作る**。アプリ側を触らずに済む。
- 案 C: **`gp3` を `ebs-sc` にリネーム**。アプリ側に合わせる。

本プロジェクトでは即時復旧のために **案 B** を取り、`terraform/storage.tf` に `ebs_sc` リソースを
追加しました：

```hcl
resource "kubernetes_storage_class_v1" "ebs_sc" {
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    type   = "gp3"
    fsType = "ext4"
  }
  depends_on = [module.eks]
}
```

これは「内容は gp3 と同じ、ただし名前が `ebs-sc`」というエイリアスです。

### 17.3 ここから学べること

- **ストレージはアプリ（Helm values）とインフラ（StorageClass）の握り合わせで動く**。
  どちらか片方の名前を変えるだけでは絶対に動かない。
- 名前は意味を持たない（k8s からすればただの識別子）が、**規約として「`gp3`」「`ebs-sc`」「`fast`」
  などの慣習名**がよく使われる。チームで `ebs-sc` を慣習にしているなら、それで揃えるのが運用しやすい。

---

# 第 V 部 EKS コントロールプレーン

## 第 18 章 EKS アーキテクチャ概要

### 18.1 コントロールプレーン vs データプレーン

EKS クラスタは大きく 2 つに分けられます：

- **コントロールプレーン**（AWS が管理）— Kubernetes API サーバー、etcd、スケジューラ、
  コントローラーマネージャー。AWS が複数 AZ で冗長化しています。利用者は直接見えません。
- **データプレーン**（ユーザーが管理）— ノードグループおよび Fargate Pod。

利用者は kubectl で API サーバーにリクエストを送り、API サーバーが etcd に書き込み、
スケジューラが Pod をノードに割り当て、kubelet（ノードのエージェント）が Pod を起動する、
という流れです。

### 18.2 API エンドポイント

`module.eks` は `cluster_endpoint_public_access = true` 設定で、**インターネット経由で API に
到達できる**設定になっています：

```
https://<random>.gr7.ap-northeast-2.eks.amazonaws.com
```

ただし、`aws eks get-token` で取得した一時トークンが必要なので、誰でも叩けるわけではありません。
セキュリティをより厳密にするには `endpoint_public_access = false` にして VPC 内からだけ
アクセスできる構成にします（その場合、CI や `terraform apply` も VPC 内で行う必要が出てきます）。

### 18.3 アクセスエントリ（access entries）

EKS 1.23 以降の機能で、IAM プリンシパル（ユーザー、ロール）に Kubernetes RBAC を結びつける
新しい方式です。以前の `aws-auth ConfigMap` よりも宣言的・安全になっています。

本プロジェクトでは：

```hcl
enable_cluster_creator_admin_permissions = true
```

を指定しています。これにより「`terraform apply` を実行した IAM 主体」にクラスタ管理者権限が
自動で付与されます。複数人で運用する場合は、`access_entries` を明示的に書いて、各人に必要な
権限のみを付与するのが推奨です。

---

## 第 19 章 OIDC プロバイダと IRSA

### 19.1 OIDC とは

OIDC（OpenID Connect）は OAuth 2.0 を拡張した認証プロトコルです。
EKS では、各クラスタが**自分自身の OIDC issuer**を持ち、それを IAM の信頼ポリシーに登録することで
「クラスタ内の特定の SA がこの IAM ロールを引き受けられる」という関係を作れます。

`module "eks"` を `terraform apply` すると、AWS 側で自動的に OIDC プロバイダリソースが作られ、
OIDC issuer URL が出力されます：

```hcl
output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}
```

例: `https://oidc.eks.ap-northeast-2.amazonaws.com/id/ABCDEF123456...`

### 19.2 IRSA の動き

(1) ServiceAccount に IAM ロール ARN のアノテーションを付ける：
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ebs-csi-controller-sa
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::208876571165:role/ktcloud-eks-ebs-csi-irsa
```

(2) ServiceAccount を使う Pod は、Pod 内に**プロジェクテッドトークン**（JWT）が自動マウントされる。

(3) AWS SDK / CLI が Pod 内で動くと、環境変数 `AWS_ROLE_ARN` と `AWS_WEB_IDENTITY_TOKEN_FILE`
を見つけ、`sts:AssumeRoleWithWebIdentity` を呼んで一時的なクレデンシャルを取得する。

(4) 取得したクレデンシャルで AWS API を叩く。

この一連の流れにより、長期クレデンシャルをコンテナ内に置く必要がなくなります。

---

## 第 20 章 EKS マネージドアドオン

### 20.1 アドオンの種類

EKS マネージドアドオンは「AWS が EKS のために配布する Kubernetes コンポーネント」を
バージョン管理して入れてくれる仕組みです。本プロジェクトで有効化しているもの：

| アドオン | 役割 |
| --- | --- |
| **coredns** | クラスタ内 DNS。Service 名 → 仮想 IP の解決 |
| **kube-proxy** | Service の仮想 IP を iptables で実装 |
| **vpc-cni** | Pod に VPC IP を直接割り当てる CNI |
| **aws-ebs-csi-driver** | EBS の動的プロビジョニング |

```hcl
# terraform/eks.tf
cluster_addons = {
  coredns = {
    most_recent = true
    configuration_values = jsonencode({
      computeType = "Fargate"
      resources = {
        limits   = { cpu = "0.25", memory = "256M" }
        requests = { cpu = "0.25", memory = "256M" }
      }
    })
  }
  kube-proxy        = { most_recent = true }
  vpc-cni           = { most_recent = true }
  aws-ebs-csi-driver = {
    most_recent              = true
    service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
  }
}
```

### 20.2 coredns を Fargate で動かす細工

CoreDNS はデフォルトでは Deployment の Pod スペックに
`eks.amazonaws.com/compute-type: ec2` のセレクタが入っており、Fargate にスケジュールされません。
これは Fargate と EC2 ノードを併用するケースで「DNS は EC2 で動かしてね」というデフォルトです。

ところが本プロジェクトでは「`kube-system` を Fargate プロファイル対象にしているのに DNS が
動かない」という矛盾が起きます。これを解決するのが上記の `configuration_values` 内の
`computeType: "Fargate"` です。EKS アドオン側に「CoreDNS は Fargate 用で起動して」と指示しています。

これで CoreDNS Pod は Fargate プロファイルにマッチし、起動できます。

---

## 第 21 章 Fargate プロファイル

### 21.1 セレクタの書き方

`fargate_profiles` の中身：

```hcl
fargate_profiles = {
  for ns in var.fargate_namespaces : ns => {
    name = "fp-${ns}"
    selectors = [{ namespace = ns }]
    subnet_ids = module.vpc.private_subnets
  }
}
```

`for` 内包で「ネームスペースのリスト」を「`{ namespace, name, selectors, subnet_ids }` のマップ」
に変換しています。`var.fargate_namespaces = ["kube-system", "argocd"]` なので、結果として
2 つのプロファイルが作られます。

セレクタは複数書けます。例えば「ネームスペース `argocd` の中でも `tier=control-plane` のラベルが
ある Pod だけ」のように絞り込めます。

### 21.2 サブネットの指定

Fargate Pod は AWS 内部で起動するマイクロ VM に**ENI** が付き、指定したサブネットの IP を 1 つ
消費します。必ず**プライベートサブネット**を指定します。
パブリックを指定するとプライベートと違って NAT 経由ではなく IGW 直結になり、不必要に攻撃面を広げます。

`module.vpc.private_subnets` は VPC モジュールの出力で、プライベートサブネットの ID の配列です。

---

# 第 VI 部 Terraform

## 第 22 章 IaC と Terraform の基本

### 22.1 IaC とは

IaC（Infrastructure as Code）はインフラ構成を**コードで宣言**して、コードからプロビジョニング・
更新・破棄まで行う手法です。手作業（コンソールクリック、CLI コピペ）では：

- 同じ環境を再現できない（手順書が更新されないので）。
- 何が今ある状態か把握できない。
- 変更履歴が残らない。

IaC はこれらを Git のコミット履歴と同列に扱える形に変換します。

### 22.2 Terraform の立ち位置

Terraform は HashiCorp 製の IaC ツールで、

- **クラウドプロバイダ非依存**（AWS、GCP、Azure、Kubernetes、Cloudflare、Datadog、...）。
- **宣言的**（「最終的にこうあってほしい」を書く。手順ではなく状態を書く）。
- **状態管理を持つ**（後述）。
- **HCL** という独自の DSL を持つ。

`terraform plan` を実行すると「現状」と「コードの宣言」を突き合わせ、差分（追加・変更・削除）を
計算します。`terraform apply` でその差分を実際に AWS API に投げます。

---

## 第 23 章 HCL 構文の基礎

### 23.1 ブロック構造

HCL（HashiCorp Configuration Language）は次のような「ブロック」で構成されます：

```hcl
<ブロックタイプ> "<ラベル1>" "<ラベル2>" {
  キー = 値
  ネスト {
    キー = 値
  }
}
```

代表例：

```hcl
# resource は「AWS の何かを作る」
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t3.medium"
}

# variable は「入力パラメータ」
variable "region" {
  type    = string
  default = "ap-northeast-2"
}

# output は「他から参照される出力」
output "ip" {
  value = aws_instance.web.public_ip
}

# locals は「式の中間変数」
locals {
  full_name = "${var.project}-${var.environment}"
}
```

### 23.2 型と式

HCL の主な型：`string`, `number`, `bool`, `list(...)`, `map(...)`, `object({...})`, `set(...)`.

式：
```hcl
"prefix-${var.name}"         # 文字列補間
[for x in var.list : x * 2]  # for 内包
{ for k, v in var.map : k => upper(v) }
length(var.list)             # 関数呼び出し
var.enable ? "yes" : "no"    # 三項演算
```

`terraform/locals.tf` の例（再掲）：
```hcl
locals {
  private_subnets = [for i, az in var.azs : cidrsubnet(var.vpc_cidr, 4, i)]
}
```

`var.azs` の各要素について `i`（インデックス）を取り出し、`cidrsubnet` で
サブネット CIDR を計算してリストにする、というコードです。

### 23.3 リソース参照

リソース同士を参照するときは `<type>.<name>.<attr>` のドット記法を使います：

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.40.0.0/16"
}

resource "aws_subnet" "a" {
  vpc_id     = aws_vpc.main.id  # ← 参照
  cidr_block = "10.40.0.0/20"
}
```

Terraform はこの参照を見て**依存関係グラフ**を自動構築し、必要な順で API を呼び出します。
`aws_subnet.a` は `aws_vpc.main.id` を必要とするので、VPC が先に作られます。

明示的に依存を書きたいときは `depends_on = [...]` を使います。
本プロジェクトでは `kubernetes_storage_class_v1.gp3` に `depends_on = [module.eks]` と書いています。
これは「EKS クラスタが完成してから StorageClass を作ってね」という指示です。
属性参照だけでは依存が分からない（kubernetes プロバイダはモジュール出力に依存しているが、
順序が曖昧な場合がある）ので、念のため明示しています。

---

## 第 24 章 プロバイダとバックエンド

### 24.1 プロバイダ

プロバイダは「特定の API を叩くプラグイン」です。`terraform/versions.tf`：

```hcl
required_providers {
  aws        = { source = "hashicorp/aws",        version = "~> 5.70" }
  kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.33" }
  helm       = { source = "hashicorp/helm",       version = "~> 2.16" }
  tls        = { source = "hashicorp/tls",        version = "~> 4.0" }
}
```

- `aws` — AWS の全 API。
- `kubernetes` — k8s クラスタの API（StorageClass、Namespace、Annotations など）。
- `helm` — Helm リリースを作る。本プロジェクトでは未使用（Ansible で入れているため）。
- `tls` — 証明書系の補助。

`~> 5.70` は「5.70 以上、5.x の最新まで OK」というバージョン制約です。
完全固定にしないことで、マイナーアップデートを取り込みやすくしています。

### 24.2 バックエンド

Terraform は**状態ファイル（tfstate）**に「何を作ったか」を記録します。
これがないと、`terraform apply` を 2 回目以降に走らせたとき「もう作った？まだ？」が判断できません。

バックエンドは tfstate の置き場所を指定します。本プロジェクトは **S3 バックエンド**で、
さらに **S3 ネイティブロック**（Terraform 1.10 以降）を使っています：

```hcl
backend "s3" {
  bucket       = "ktcloud-terraform-208876571165-ap-northeast-2-an"
  key          = "provisioning/terraform.tfstate"
  region       = "ap-northeast-2"
  encrypt      = true
  use_lockfile = true   # ← S3 ネイティブロック
}
```

- `bucket` / `key` — どの S3 バケットのどのキーに置くか。
- `encrypt = true` — サーバーサイド暗号化を強制。
- `use_lockfile = true` — ロックファイル `.tflock` を同じ S3 に置く。これで複数人が同時に
  `apply` してもロックが取られる。**従来 DynamoDB が必要だった「ロックテーブル」が不要**になりました。

### 24.3 状態の操作

`terraform state` サブコマンドで状態を直接弄れます：

- `terraform state list` — 現在管理しているリソース一覧。
- `terraform state show <addr>` — 個別の詳細表示。
- `terraform state rm <addr>` — 状態からだけ削除（リソースは AWS に残る）。
- `terraform import <addr> <id>` — 既存リソースを状態に取り込む。

これらは「壊れた状態を直したい」「リネームしたい」ときの最終手段です。普段は使いません。

---

## 第 25 章 モジュールと再利用

### 25.1 モジュールとは

モジュールは「Terraform コードの再利用可能な単位」です。
ローカル相対パスで作るローカルモジュール、Git/Registry から取ってくる外部モジュールがあります。

本プロジェクトは**コミュニティ公式モジュール**を 2 つ使っています：

```hcl
# VPC モジュール
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.13"
  # ...
}

# EKS モジュール
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"
  # ...
}
```

これらは「VPC / EKS 構築の事実上の標準モジュール」で、内部的に数十のリソース
（サブネット、ルートテーブル、IGW、NAT、SG、IAM ロール、...）を一括で作ってくれます。
自分で全部書こうとすると 500 行コースですが、モジュールを使うと 30 行で済みます。

### 25.2 モジュールの呼び出し方

モジュール呼び出しは `module "<name>" {}` ブロックで、`source` と `version` を指定し、
あとは入力変数を渡します。出力は `module.<name>.<output_name>` で参照できます。

例えば `module.vpc.vpc_id` は VPC モジュールが返す VPC ID で、これを EKS モジュールの
`vpc_id = module.vpc.vpc_id` に渡しています。

---

## 第 26 章 本プロジェクトの Terraform コード解読

### 26.1 ファイル分割の指針

| ファイル | 役割 |
| --- | --- |
| `versions.tf` | Terraform / プロバイダのバージョン、バックエンド |
| `providers.tf` | プロバイダの設定（リージョン、認証） |
| `variables.tf` | 入力変数の定義 |
| `locals.tf` | 計算ローカル値 |
| `vpc.tf` | VPC モジュール呼び出し |
| `eks.tf` | EKS モジュール、Fargate プロファイル、IRSA |
| `storage.tf` | StorageClass、gp2 デフォルト解除 |
| `outputs.tf` | 出力値 |
| `terraform.tfvars.example` | 変数の例（コピーして `terraform.tfvars` に） |

Terraform はファイル名を見ません。同じディレクトリ内のすべての `.tf` を結合して解釈します。
分割は人間のための整理に過ぎませんが、「どこに何があるか」が直感的に分かることが重要です。

### 26.2 各ファイルの要点

#### providers.tf

```hcl
provider "aws" {
  region = var.region
  default_tags { tags = var.tags }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", var.region]
  }
}
```

`kubernetes` プロバイダは EKS の API に接続するために**毎回 `aws eks get-token` を実行**します。
これは ID トークンを STS で発行する仕組みで、Kubernetes プロバイダがそのトークンをベアラとして
API リクエストに付けてくれます。

#### variables.tf

入力パラメータの一覧。本プロジェクトのデフォルトは：

- リージョン `ap-northeast-2`
- プロジェクト名 `ktcloud-eks`
- Kubernetes バージョン `1.31`
- VPC CIDR `10.40.0.0/16`
- AZ 3 つ、Fargate ネームスペース 2 つ、ノードグループ `t3.medium` × 2

これらを変えたいときは `terraform.tfvars` を作って上書きします：
```hcl
region          = "ap-northeast-1"
cluster_version = "1.32"
```

#### outputs.tf

`terraform output` で表示される出力。`cluster_name`, `cluster_endpoint`,
`cluster_oidc_issuer_url`, `region`, `kubeconfig_command` などを返します。

特に `kubeconfig_command` は便利で、`terraform output kubeconfig_command` の結果をそのまま
シェルに貼ると kubeconfig が更新されます。

### 26.3 デプロイの順序（依存関係）

`terraform apply` 一発で全部作りますが、内部的には次の順で進みます：

```
1. VPC, IGW, NAT, サブネット, ルートテーブル
2. EKS クラスタ（コントロールプレーン）—— ここで 8〜12 分
3. OIDC プロバイダの登録
4. IRSA 用 IAM ロール
5. EKS アドオン × 4（CoreDNS は最後の方）
6. Fargate プロファイル × 2（順番に作られる、各 2〜3 分）
7. マネージドノードグループ
8. StorageClass（gp3, ebs-sc）と gp2 のデフォルト解除
```

合計で 20〜25 分かかります。

---

# 第 VII 部 Ansible

## 第 27 章 Ansible の基本概念

### 27.1 Ansible とは

Ansible は Red Hat 製の**構成管理ツール**です。

- **エージェントレス**: 管理対象に何も入れる必要がない。SSH（または `local` 接続）で十分。
- **YAML ベース**: 全部 YAML で書ける。
- **冪等性**: 同じプレイブックを 2 回流しても、最終状態が同じになる（変更なし → 何もしない）。
- **大量のモジュール**: ファイル、サービス、パッケージ、Kubernetes、AWS、Helm など、ほぼ何でもある。

Terraform は「リソースの作成・更新・削除」が中心ですが、Ansible は「**そのリソースの中で何かする**」
（パッケージ入れる、設定ファイル書く、サービス再起動）に強いです。
両者は競合しません。本プロジェクトのように Terraform → Ansible と段階を分けるのは王道です。

### 27.2 本プロジェクトでの Ansible の役割

Terraform で EKS クラスタが立ったあと、Ansible は次を行います：

1. ローカルの kubeconfig を更新する（`aws eks update-kubeconfig`）。
2. Helm v3 バイナリをプロジェクト内 `bin/` に配置する（理由は第 36 章）。
3. クラスタが疎通しているか確認する。
4. ArgoCD を Helm でインストールする。
5. ArgoCD の root Application を Apply する。

つまり**「クラスタの中身を 1 ファイル GitOps 化するためのブートストラップ」**です。
これ以降のアプリ追加は ArgoCD（つまりマニフェストリポへの git push）で行います。

---

## 第 28 章 インベントリ、プレイブック、タスク

### 28.1 インベントリ

インベントリは「どのホストを管理するか」のリストです。本プロジェクトは**ローカル接続のみ**:

```yaml
# ansible/inventory.yml
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
```

`localhost` を `local` 接続で扱う（SSH せず、その場で実行する）設定です。
EKS は API でリモート操作するので、Ansible 的にはローカルマシンの上で kubectl/helm を回しているだけ
というイメージです。

### 28.2 プレイブック

プレイブックは「プレイのリスト」、プレイは「ホスト群に対するタスクのリスト」です。

```yaml
# ansible/site.yml
- import_playbook: playbooks/bootstrap.yml
- import_playbook: playbooks/argocd.yml
```

`site.yml` は「全部やる」の入り口。中身は他の 2 プレイブックを順に取り込みます。

### 28.3 タスクの基本形

```yaml
- name: Ensure aws CLI is installed
  ansible.builtin.command: aws --version
  register: aws_version
  changed_when: false
```

- `name` — 表示用の名前。
- `ansible.builtin.command` — モジュール名。引数を渡している。
- `register` — このタスクの結果を変数に格納する。
- `changed_when: false` — 「このタスクは状態を変えないので `changed` 扱いしない」と教える。

冪等性を保つ上で `changed_when` は重要です。`command` モジュールは「呼ばれたら毎回 `changed=true`」
になる素朴な作りなので、本当に状態を変えていないなら `false` と明示してあげます。

---

## 第 29 章 モジュールと冪等性

### 29.1 主要モジュール

本プロジェクトで使うモジュール：

| モジュール | 用途 |
| --- | --- |
| `ansible.builtin.command` | コマンド実行（`aws`, `tar`, `helm`） |
| `ansible.builtin.file` | ディレクトリ作成、権限 |
| `ansible.builtin.stat` | ファイル存在チェック |
| `ansible.builtin.get_url` | ファイルダウンロード |
| `ansible.builtin.copy` | ファイルコピー（リモート→ローカル含む） |
| `ansible.builtin.set_fact` | 動的に変数を設定 |
| `ansible.builtin.debug` | 出力 |
| `kubernetes.core.k8s` | k8s リソースの Apply |
| `kubernetes.core.k8s_info` | k8s リソースの取得 |
| `kubernetes.core.helm` | Helm リリースの管理 |
| `kubernetes.core.helm_repository` | Helm リポジトリの追加 |

### 29.2 冪等性のための条件付き実行

Helm v3 バイナリは「あればダウンロードしない」を実現する必要があります。
`bootstrap.yml` の該当箇所：

```yaml
- name: Check for pinned helm binary
  ansible.builtin.stat:
    path: "{{ helm_binary_path }}"
  register: helm_stat

- name: Download helm v{{ helm_version }} archive
  ansible.builtin.get_url:
    url: "https://get.helm.sh/helm-v{{ helm_version }}-{{ helm_os }}-{{ helm_arch }}.tar.gz"
    dest: "/tmp/helm-v{{ helm_version }}-{{ helm_os }}-{{ helm_arch }}.tar.gz"
    mode: "0644"
  when: not helm_stat.stat.exists
```

`stat` でファイルの存在を確認 → `when: not helm_stat.stat.exists` で「無いときだけダウンロード」
にしています。2 回目以降の実行ではダウンロードがスキップされます。

`command` モジュールには `creates:` という便利オプションがあり、

```yaml
- name: Extract helm archive
  ansible.builtin.command:
    cmd: tar -xzf /tmp/helm-...tar.gz -C /tmp
    creates: "/tmp/{{ helm_os }}-{{ helm_arch }}/helm"
```

「`creates` のパスが既にあれば、コマンドを実行しない」と動きます。
これも冪等性を担保するワザです。

### 29.3 group_vars と変数優先度

`ansible/group_vars/all.yml` はインベントリの `all` グループ全体に適用される変数を定義します：

```yaml
aws_region: ap-northeast-2
cluster_name: ktcloud-eks
helm_version: "3.16.4"
helm_binary_dir: "{{ playbook_dir }}/../bin"
helm_binary_path: "{{ helm_binary_dir }}/helm"
argocd_namespace: argocd
argocd_chart_version: "7.7.10"
argocd_manifest_repo_url: https://github.com/kanei0415/ktcloud-k8s-argocd-manifest.git
argocd_root_path: Setup
```

これらの値はプレイブック内から `{{ aws_region }}` のように参照できます。
変数の優先度（高 → 低）は概ね「`--extra-vars` > `set_fact` > host_vars > group_vars > defaults」です。
コマンドラインで上書きしたいときは `ansible-playbook ... -e helm_version=3.17.3` のように渡します。

---

## 第 30 章 本プロジェクトの Ansible コード解読

### 30.1 bootstrap.yml — クラスタの足回り整備

このプレイブックは大きく 3 つのセクションに分かれます：

(A) ツール存在確認（aws CLI、kubectl）。

(B) プロジェクト内 Helm v3 バイナリの自動配備：
1. `uname -s` / `uname -m` で OS / アーキを取得。
2. `set_fact` で `helm_os`、`helm_arch` を計算（`darwin/arm64` のように）。
3. `bin/` を作る → なければ `https://get.helm.sh/...tar.gz` を取得 → `tar -xzf` → `cp` で
   `ansible/bin/helm` に配置。

(C) `aws eks update-kubeconfig` で kubeconfig 更新 → k8s_info でノード一覧取って疎通確認。

### 30.2 argocd.yml — ArgoCD のインストールと root-app

```yaml
- name: Add Argo Helm repository
  kubernetes.core.helm_repository:
    binary_path: "{{ helm_binary_path }}"
    name: "{{ argocd_helm_repo_name }}"
    repo_url: "{{ argocd_helm_repo_url }}"

- name: Ensure argocd namespace exists
  kubernetes.core.k8s:
    kubeconfig: "{{ kubeconfig_path }}"
    state: present
    definition:
      apiVersion: v1
      kind: Namespace
      metadata: { name: "{{ argocd_namespace }}" }

- name: Install/upgrade ArgoCD Helm release
  kubernetes.core.helm:
    binary_path: "{{ helm_binary_path }}"
    name: "{{ argocd_release_name }}"
    chart_ref: "{{ argocd_chart_ref }}"
    chart_version: "{{ argocd_chart_version }}"
    release_namespace: "{{ argocd_namespace }}"
    wait: true
    wait_timeout: 10m
    values_files: [ "{{ argocd_values_file }}" ]
```

特徴：

- `binary_path` で「先ほどダウンロードした v3 バイナリを使え」と明示している。
- `wait: true` で「全 Pod が Ready になるまで待ってから次に進む」。
- `values_files` でカスタム values を渡し、Fargate 用にリソースを絞る。

最後に root-app を Apply：

```yaml
- name: Apply ArgoCD root Application (App-of-Apps)
  kubernetes.core.k8s:
    kubeconfig: "{{ kubeconfig_path }}"
    state: present
    definition: "{{ lookup('template', '../templates/root-app.yaml.j2') | from_yaml }}"
    apply: true
```

`lookup('template', ...)` で Jinja テンプレートを評価し、`from_yaml` で YAML をオブジェクトに
パースしてから `definition:` に渡しています。Apply は `kubectl apply -f` と同じセマンティクスです。

### 30.3 root-app.yaml.j2 の中身

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ argocd_root_app_name }}
  namespace: {{ argocd_namespace }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: {{ argocd_manifest_repo_url }}
    targetRevision: {{ argocd_manifest_repo_revision }}
    path: {{ argocd_root_path }}
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: {{ argocd_namespace }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ApplyOutOfSyncOnly=true
```

- `path: Setup` + `directory.recurse: true` — マニフェストリポの `Setup/` 配下の YAML を全部 Apply。
- `prune: true` — Git から消えた k8s リソースをクラスタからも削除。
- `selfHeal: true` — クラスタを手で変更しても Git の状態に勝手に戻す。
- `CreateNamespace=true` — ネームスペースが無ければ作る。

---

# 第 VIII 部 ArgoCD と GitOps

## 第 31 章 GitOps の考え方

### 31.1 Push 型 vs Pull 型

伝統的な CI/CD は **Push 型**でした：

```
GitHub Push → CI が build → CI が kubectl apply / helm install
```

CI が **クラスタの認証情報を持つ**必要があり、CI 環境が漏れるとクラスタも危ない、
という構造的問題があります。

**Pull 型（GitOps）**は逆向き：

```
GitHub に置く（マニフェスト or Helm values）
  ↑   ↓ (ArgoCD が定期 pull)
クラスタ内の ArgoCD が apply
```

クラスタが Git を見にいくので、CI に kubeconfig を渡す必要がなくなります。
**Git が単一の真実の源**になり、Git の履歴 = クラスタの履歴になります。

### 31.2 ArgoCD のコンポーネント

| コンポーネント | 役割 |
| --- | --- |
| **argocd-server** | Web UI / API |
| **argocd-repo-server** | Git クローン、Helm/Kustomize レンダリング |
| **application-controller** | クラスタの実状と Git の差分を見て調停 |
| **applicationset-controller** | ApplicationSet を展開して個別 Application を作る |
| **redis** | キャッシュ |

---

## 第 32 章 Application と ApplicationSet

### 32.1 Application

`Application` は ArgoCD が同期する **1 つの単位**。具体的には：

- `source.repoURL` — どの Git リポジトリ。
- `source.path` — リポジトリ内のどのディレクトリ。
- `source.targetRevision` — どの branch / tag / commit。
- `destination.server` — どのクラスタの API。
- `destination.namespace` — どのネームスペースに Apply。
- `syncPolicy` — 同期戦略。

これだけです。ディレクトリの中身が「素の YAML」なら kubectl apply 相当、`Chart.yaml` があれば Helm
としてレンダリング、`kustomization.yaml` があれば Kustomize としてレンダリング、と
**ArgoCD が自動検出**します。

### 32.2 ApplicationSet

`ApplicationSet` は「**複数の Application を機械的に生成するテンプレ**」です。
本プロジェクトのマニフェストリポ `Setup/Addons-app.yaml` を例にすると：

```yaml
kind: ApplicationSet
metadata:
  name: addons-app
spec:
  generators:
    - list:
        elements:
          - path: Addons/Postgresql
            appname: postgresql
            ns: postgresql
          - path: Addons/Redis
            appname: redis
            ns: redis
          - path: Addons/Kafka
            appname: kafka
            ns: kafka
  template:
    metadata:
      name: '{{appname}}'
    spec:
      source:
        repoURL: "https://github.com/kanei0415/ktcloud-k8s-argocd-manifest.git"
        path: '{{path}}'
      destination:
        namespace: '{{ns}}'
      syncPolicy:
        automated: { prune: true, selfHeal: true }
```

`list` ジェネレータで 3 要素を回し、`template` を展開して 3 つの Application を作ります。
ジェネレータには他にも `git`（リポ内の特定パスを総なめ）、`cluster`（複数クラスタに同じ App）、
`matrix`（複数ジェネレータを組み合わせる）等があり、複雑な構成に対応できます。

---

## 第 33 章 App-of-Apps パターン

### 33.1 一段目の Application が「App 集」を指す

**App-of-Apps** は、ArgoCD で多数のアプリケーションを管理するときの定番パターンです：

```
root-app  ──pulls──►  Setup/Addons-app.yaml      ──spawns──►  postgresql App
                      Setup/Apps.yaml             ──spawns──►  redis App
                      Setup/Charts-app.yaml       ──spawns──►  kafka App
                                                                ktcloud-market App
                                                                traefik App
```

`root-app` は 1 つの Application でしかありませんが、その中身が「ApplicationSet が並んだディレクトリ」
なので、root-app を sync すると ApplicationSet が作られ、それぞれが子 Application を作り…
と連鎖的に展開されます。

### 33.2 なぜこの形か

- **クラスタを bootstrap するときに 1 個だけ apply すればいい**（→ Ansible が 1 個だけ apply している）。
- 「アプリの集合」を Git で増減できる。新しい App を足したいなら `Setup/` に YAML を 1 つ追加するだけ。
- root-app を `directory.recurse: true` で運用すれば、`Setup/` 配下の追加は完全に自動拾い。

---

## 第 34 章 本プロジェクトの ArgoCD セットアップ

### 34.1 values.yaml のチューニング方針

`ansible/files/argocd-values.yaml` は次のポリシーで書かれています：

- **HA は無効**（`replicas: 1`）。学習・開発用なので。
- **dex / notifications を無効**。Fargate コストを抑えるため。
- **`server.insecure: "true"`**。クラスタ内に Traefik が入ったら、Traefik が TLS 終端し
  ArgoCD は HTTP で受ける構成。
- **repo-server のメモリは 2 GiB**。Bitnami の index.yaml をパースするのに必要（第 39 章）。

```yaml
configs:
  params:
    server.insecure: "true"

server:
  replicas: 1
  service: { type: ClusterIP }
  resources:
    requests: { cpu: 100m, memory: 256Mi }
    limits:   { cpu: 500m, memory: 512Mi }

repoServer:
  replicas: 1
  resources:
    requests: { cpu: 250m, memory: 1Gi }
    limits:   { cpu: 1000m, memory: 2Gi }

controller:
  replicas: 1
  resources:
    requests: { cpu: 250m, memory: 512Mi }
    limits:   { cpu: 1000m, memory: 1Gi }

dex:          { enabled: false }
notifications:{ enabled: false }
```

### 34.2 初回ログイン

ArgoCD は初回起動時に admin パスワードを Secret として生成します：

```bash
make argocd-password   # → bcrypt 前のパスワードを表示
make argocd-ui         # → localhost:8080 にポートフォワード
```

UI で `admin` / 表示されたパスワードでログイン。本来はパスワードを変更し、初期 Secret を削除する
運用にすべきです（`kubectl -n argocd delete secret argocd-initial-admin-secret`）。

---

# 第 IX 部 実際に発生したトラブルとその解決

ここからは「教科書通りに進めても引っかかる」現実の障害集です。
各章で「症状 → 原因 → 直し方 → 学び」をセットで記録します。

## 第 35 章 community.general.yaml コールバック削除

### 症状
```
[ERROR]: The 'community.general.yaml' callback plugin has been removed.
```

`ansible-playbook` を起動した瞬間に出ました。

### 原因
`ansible/ansible.cfg` で `stdout_callback = yaml` を指定していました。
これは古い `community.general.yaml` を参照しに行きますが、`community.general` 12.0.0 で
当該プラグインが削除されました。`ansible-core` 2.13 以降は同等機能が組み込みの
`ansible.builtin.default` + `result_format: yaml` で実現できるので、コールバック自体は不要に
なっていました。

### 直し方
```ini
# ansible/ansible.cfg
stdout_callback = ansible.builtin.default
result_format = yaml
```

### 学び
- コレクションのアップグレードで「黙って削除されるプラグイン」がある。
- 代替がある場合、ドキュメントに移行手順が書かれていることが多い。エラーメッセージで検索する。

---

## 第 36 章 Helm 4 と kubernetes.core の互換問題

### 症状
```
[ERROR]: Module failed: Helm version must be >=3.0.0,<4.0.0, current version is 4.1.4
```

### 原因
ローカル macOS の `helm` が v4.1.4（Homebrew で最新版がインストールされていた）。
`kubernetes.core` コレクションの helm モジュールは Helm 3 系のみサポートしており、v4 では拒否されます。
これは Helm 4 が出てから数か月、コレクション側がまだ正式対応していないためです。

### 直し方
ユーザのグローバル helm を**ダウングレードせず**、プロジェクト内に Helm v3 を「pin」する方針を取りました。

1. `group_vars/all.yml` に `helm_version: "3.16.4"`, `helm_binary_path: ".../bin/helm"` を定義。
2. `bootstrap.yml` で OS / アーキを判定して `get.helm.sh` から tar.gz をダウンロード → 展開 → `bin/helm` に配置。
3. `argocd.yml` の `helm_repository` / `helm` タスクに `binary_path: "{{ helm_binary_path }}"` を渡す。

これにより、グローバル環境を汚さずに Helm v3 を強制できます。

### 学び
- ローカルの CLI バージョンは「コレクション・ライブラリの想定範囲」と一致しないことがある。
- そうなったときは「グローバルを変える」「プロジェクト内に pin する」のどちらか。再現性の観点で **pin を強く推奨**。
- `binary_path` のような「特定のバイナリを使え」というオプションを持つモジュールが多い。

---

## 第 37 章 macOS の BSD tar と unarchive モジュール

### 症状
Helm のアーカイブ展開でエラー：
```
Command "/usr/bin/tar" detected as tar type bsd. GNU tar required.
```

### 原因
`ansible.builtin.unarchive` モジュールは GNU tar に依存していて、macOS の BSD tar を拒否します。
fallback で unzip を試すが、`.tar.gz` は zip じゃないので失敗。

### 直し方
`unarchive` を使うのを諦め、`command` モジュールで直接 `tar -xzf` を呼ぶ：

```yaml
- name: Extract helm archive
  ansible.builtin.command:
    cmd: tar -xzf /tmp/helm-...tar.gz -C /tmp
    creates: "/tmp/{{ helm_os }}-{{ helm_arch }}/helm"
  when: not helm_stat.stat.exists
```

BSD tar は `.tar.gz` をちゃんと展開できます。Ansible のモジュールが頑なに拒否していただけでした。

### 学び
- Ansible のモジュールは「期待する環境」が暗黙にある。
- それを満たせない時は、`command` / `shell` でストレートに呼ぶのが最短ルート。
- `creates: <path>` を付ければ冪等性も保てる。

---

## 第 38 章 ArgoCD Helm values の global: null 問題

### 症状
```
template: argo-cd/templates/_common.tpl:38:37: executing "argo-cd.defaultTag"
  at <.Values.global.image.tag>: nil pointer evaluating interface {}.image
```

### 原因
`argocd-values.yaml` の冒頭が次のようになっていました：

```yaml
global:

configs:
  ...
```

YAML の仕様上、`global:` の後に値がないと **`global: null`** と解釈されます。
すると Helm テンプレート内で `.Values.global.image.tag` を参照したときに、`null.image` で
nil pointer 例外になります。

### 直し方
空の `global:` ブロック自体を削除：

```yaml
configs:
  params:
    server.insecure: "true"
  ...
```

`global:` のデフォルトはチャート側に書かれているので、何も上書きしないなら**書かない**のが正しい。

### 学び
- YAML で「キーだけ書いて値を書かない」は明示的に **null** を指定したのと同じ。
- 上書きしないなら書かない。書くなら必ず子の値を埋める。
- Helm の `_common.tpl` などのテンプレヘルパは「`.Values.X` は dict である」前提で書かれていることが多く、
  null だとクラッシュする。

---

## 第 39 章 argocd-repo-server の OOMKilled と Bitnami

### 症状
ArgoCD UI 上、Postgres / Redis Application が次のエラー：
```
failed to add helm repository https://charts.bitnami.com/bitnami:
... helm repo add ... failed signal: killed
```

### 原因
`kubectl describe pod` を見ると `OOMKilled`：
```
lastState.terminated.reason: OOMKilled
limits.memory:               512Mi
```

ArgoCD repo-server は Application の差分計算のために `helm repo add` を呼びますが、
**Bitnami の `index.yaml` は約 600 MB**（チャート × 全バージョンの巨大カタログ）あり、
helm がこれをメモリに展開する際に 1 GB 以上消費します。512Mi の上限ではほぼ確実に OOM します。

### 直し方
`argocd-values.yaml` の `repoServer.resources.limits.memory` を `2Gi` に増量：

```yaml
repoServer:
  resources:
    requests:
      cpu: 250m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
```

その上で `make ansible-argocd` を再実行。新しい repo-server Pod は 2 GiB で動き、Bitnami を
ロードできるようになります。

### 学び
- `signal: killed` は OOMKilled の典型的な表れ。`kubectl describe` で確認できる。
- 外部 Helm リポジトリのサイズはコレクションの規模によって極端。
  特に Bitnami のような「あらゆる OSS チャートを揃えるカタログ系」は重い。
- Pod のリソース上限は「定常状態」だけでなく**「スパイク時」を見越して決める**。
- 2025 年現在、Bitnami は構成変更を進めており、`charts.bitnami.com/bitnami` の主要チャートが
  サブスク化される動きがある。長期的にはチャートの移行や代替（postgres-operator, valkey 等）も
  検討対象。

---

## 第 40 章 ebs-sc StorageClass 欠落

### 症状
Pod イベント：
```
ProvisioningFailed: storageclass.storage.k8s.io "ebs-sc" not found
```

### 原因
マニフェストリポの `Addons/Postgresql/values.yaml` と `Addons/Redis/values.yaml` が
`storageClass: "ebs-sc"` をハードコードしているが、本プロジェクトが Terraform で作っている
StorageClass は `gp3`（デフォルト）と `gp2`（非デフォルト）だけ。名前の不一致。

### 直し方
`terraform/storage.tf` に `ebs-sc` という StorageClass を追加（中身は gp3 と同じ）：

```hcl
resource "kubernetes_storage_class_v1" "ebs_sc" {
  metadata { name = "ebs-sc" }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = { type = "gp3", fsType = "ext4" }
  depends_on = [module.eks]
}
```

差分だけを適用：
```bash
cd terraform && terraform apply -target=kubernetes_storage_class_v1.ebs_sc
```

### 学び
- ストレージは「アプリの要求名」と「インフラの提供名」の握り合わせ。
- どちらか片方の変更だけでは動かない。
- 「アプリ側を直す」「インフラ側に別名を作る」両方の選択肢がある。即時復旧重視なら後者。

---

## 第 41 章 残課題: Kafka の nfs-client

### 症状
（まだ起きてはいないが、Postgres/Redis が動いた後で起きる可能性が高い）
Kafka が `nfs-client` StorageClass を要求するが、クラスタには存在しない。

### 原因
`Addons/Kafka/values.yaml` が `storageClass: "nfs-client"` を指定している。
本プロジェクトには NFS 系の StorageClass は存在しない（EFS CSI も未導入）。

### 想定される対処の選択肢

#### 案 A: マニフェストリポを修正

`Addons/Kafka/values.yaml` の `storageClass` を `"ebs-sc"` に変更する。
**Kafka に NFS は実は推奨されない**ので、ストレージの観点ではこちらが望ましい。
ただしマニフェストリポ側の PR が必要。

#### 案 B: EFS CSI + nfs-client StorageClass を Terraform に追加

```hcl
# 概念コード
resource "aws_efs_file_system" "kafka" { ... }
resource "aws_efs_mount_target" "kafka" { ... } # 各 AZ
module "efs_csi_irsa" { ... }
# EFS CSI ドライバーアドオン
# StorageClass nfs-client (provisioner: efs.csi.aws.com)
```

労力は中程度。Kafka の性能は EBS より劣る。

#### 案 C: `ebs-sc` のときと同じ手で「nfs-client という名前の gp3」を作る

`ebs-sc` と同じ発想で `terraform/storage.tf` にもう 1 つ書く：

```hcl
resource "kubernetes_storage_class_v1" "nfs_client" {
  metadata { name = "nfs-client" }
  storage_provisioner = "ebs.csi.aws.com"
  # 中身は gp3
}
```

これは「名前が NFS を装っているが中身は EBS」という嘘なので、運用上は混乱を招きます。
緊急避難として一時的に使うなら可。

本プロジェクトの方針は基本的に **案 A**（マニフェストリポを正す）です。

### 学び
- 同じ「StorageClass 不一致」でも、選び方の正解は文脈による。
- Kafka のような「I/O 特性が結果に直結するワークロード」は、表面のエラーを潰す前に
  そもそも適切なストレージ選択になっているかを確認するべき。

---

# 第 X 部 付録

## 第 42 章 用語集

| 用語 | 説明 |
| --- | --- |
| AMI | Amazon Machine Image。EC2 用の OS イメージ |
| AZ | Availability Zone。リージョン内の独立データセンター |
| AWS LB Controller | Service/Ingress から ALB/NLB を作るコントローラ |
| ApplicationSet | 複数 Application を生成する ArgoCD CRD |
| CSI | Container Storage Interface。k8s と外部ストレージの仕様 |
| CIDR | IP アドレスのレンジ表記。`10.40.0.0/16` 等 |
| DaemonSet | 全ノードに 1 Pod ずつ走らせる k8s リソース |
| EBS | Elastic Block Store。AWS のブロックストレージ |
| EFS | Elastic File System。AWS の NFS ストレージ |
| EKS | Elastic Kubernetes Service。AWS の k8s マネージドサービス |
| ENI | Elastic Network Interface。仮想 NIC |
| Fargate | サーバーレスコンテナ実行基盤 |
| GitOps | Git を真実の源とするデプロイ手法 |
| Helm | k8s 用のパッケージマネージャ |
| HCL | HashiCorp Configuration Language。Terraform の DSL |
| IaC | Infrastructure as Code |
| IAM | Identity and Access Management |
| IGW | Internet Gateway |
| IRSA | IAM Roles for Service Accounts |
| Kustomize | k8s マニフェストのオーバーレイツール |
| NAT | Network Address Translation |
| NACL | Network ACL。サブネット単位の FW |
| OIDC | OpenID Connect。認証プロトコル |
| PV | PersistentVolume |
| PVC | PersistentVolumeClaim |
| RBAC | Role-Based Access Control |
| SC | StorageClass |
| SG | Security Group |
| StatefulSet | 順序・永続を伴う Pod セット |
| VPC | Virtual Private Cloud |

---

## 第 43 章 よく使うコマンドチートシート

### 43.1 Terraform

```bash
# 初期化（プロバイダ DL、バックエンド接続）
make tf-init
# あるいは
cd terraform && terraform init

# 整形
make tf-fmt

# 構文チェック
make tf-validate

# 差分の確認（plan）
make tf-plan
# あるいは
cd terraform && terraform plan -out tfplan

# 適用
make tf-apply

# 出力確認
make tf-output

# 特定リソースだけ適用
cd terraform && terraform apply -target=kubernetes_storage_class_v1.ebs_sc

# 破棄
make tf-destroy

# 状態確認
cd terraform && terraform state list
cd terraform && terraform state show module.eks.aws_eks_cluster.this[0]
```

### 43.2 Ansible

```bash
# コレクション取得
make ansible-deps

# 構文チェック
ansible-playbook --syntax-check -i ansible/inventory.yml ansible/site.yml

# 単体プレイブック
make ansible-bootstrap
make ansible-argocd

# 全部
make ansible-all

# 変数の上書き
cd ansible && ansible-playbook -e helm_version=3.17.3 playbooks/bootstrap.yml

# Dry-run（変更しない、差分だけ）
cd ansible && ansible-playbook --check site.yml

# 詳細出力
cd ansible && ansible-playbook -vvv site.yml
```

### 43.3 kubectl

```bash
# kubeconfig 更新
make kubeconfig
# あるいは
aws eks update-kubeconfig --name ktcloud-eks --region ap-northeast-2

# ノード一覧
kubectl get nodes -o wide

# 全ネームスペースの Pod
kubectl get pods -A

# StorageClass 一覧
kubectl get storageclass

# Application / ApplicationSet（ArgoCD）
kubectl -n argocd get applications
kubectl -n argocd get applicationsets

# 特定の Pod を describe
kubectl -n argocd describe pod argocd-repo-server-xxxx

# ログ
kubectl -n argocd logs deploy/argocd-server -f

# ポートフォワード
make argocd-ui
# あるいは
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

### 43.4 ArgoCD（UI なし、kubectl から）

```bash
# 強制 sync
kubectl -n argocd patch app/<name> --type merge -p '{"operation":{"sync":{}}}'

# 削除（cascade）
kubectl -n argocd delete application <name>

# 初期パスワード取得
make argocd-password
```

### 43.5 AWS CLI（よく使うやつ）

```bash
# EKS クラスタの状態
aws eks describe-cluster --name ktcloud-eks --region ap-northeast-2 \
  --query 'cluster.status'

# kubeconfig 更新
aws eks update-kubeconfig --name ktcloud-eks --region ap-northeast-2

# OIDC issuer URL（IRSA で必要）
aws eks describe-cluster --name ktcloud-eks --region ap-northeast-2 \
  --query 'cluster.identity.oidc.issuer'
```

---

## 第 44 章 学習ロードマップ

本書を読み終えた後に挑むと良い順序：

### Step 1: 動かしてみる
1. `make tf-init && make tf-plan` で計画を読む。出力の各リソースが第 II〜V 部のどれに該当するか
   答えられるようにする。
2. `make tf-apply` を流し、20 分待つ。`aws eks describe-cluster` で `ACTIVE` を確認。
3. `make ansible-all` で ArgoCD を入れ、`make argocd-ui` で UI を開く。
4. ArgoCD の各 Application のステータスを確認する。

### Step 2: 一カ所だけ変える
1. ノードグループのインスタンスタイプを `t3.medium` → `t3.large` に変更。
2. `terraform plan` で差分を読む（ノードグループの再作成 or インプレース更新どちらになる？）。
3. `terraform apply`。挙動を観察。

### Step 3: 新しいネームスペースを Fargate に追加
1. `var.fargate_namespaces` に `"my-app"` を足す。
2. `terraform apply -target=module.eks` で Fargate プロファイルだけ追加。
3. その NS に Pod を作って Fargate に着地することを確認。

### Step 4: AWS Load Balancer Controller を入れる
1. Terraform に IRSA + Helm Release を追加。
2. `make argocd-ui` を `kubectl port-forward` ではなく Ingress 経由にする。

### Step 5: マニフェストリポを所有する
1. `ktcloud-k8s-argocd-manifest` を fork する。
2. `Addons/Kafka/values.yaml` の `storageClass` を `ebs-sc` に変更。
3. fork した URL を `ansible/group_vars/all.yml` の `argocd_manifest_repo_url` に設定。
4. ArgoCD が新しい設定を反映することを確認。

### Step 6: 本番化に向けて
- バックエンド S3 にバージョニング / オブジェクトロックを付ける。
- `single_nat_gateway = false` で AZ ごとに NAT。
- ノードグループに Spot を混ぜる、Cluster Autoscaler / Karpenter を導入。
- ArgoCD を HA 構成、Dex で SSO、TLS 終端を Traefik で。
- 監視（Prometheus, Grafana, Loki）と通知。
- バックアップ（Velero）。

---

## おわりに

ここまで読んでくださりありがとうございました。
本書は「動くものを作る」と「中身を理解する」を同時に進められるように、
**実物のコード**と**実際の障害**を全部教材にしました。

EKS、Terraform、Ansible、ArgoCD は単体でも分厚いトピックですが、
**1 つのプロジェクトに串刺しで触る経験**は何にも代えがたい近道です。
本書がその第一歩になれば幸いです。

次の一歩は、第 44 章のロードマップを 1 つ進めてみてください。
動かし、壊し、直す——それが最も速い学習方法です。

---

**EOF**
