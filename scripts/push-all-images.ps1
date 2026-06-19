param(
  [string]$Region = "ap-south-1",
  [string]$Tag = "latest",
  [string]$FrontendApiUrl = "",
  [switch]$SkipTerraformOutput
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$terraformDir = Resolve-Path (Join-Path $scriptDir "..")
$repoRoot = Resolve-Path (Join-Path $terraformDir "..")

$services = @(
  @{ Name = "medicojob-api-gateway"; Path = "medicojob-api-gateway"; BuildArgs = @() },
  @{ Name = "medicojob-user-service"; Path = "medicojob-user-service"; BuildArgs = @() },
  @{ Name = "medicojob-job-service"; Path = "medicojob-job-service"; BuildArgs = @() },
  @{ Name = "medicojob-matching-service"; Path = "medicojob-matching-service"; BuildArgs = @() },
  @{ Name = "medicojob-availability-service"; Path = "medicojob-availability-service"; BuildArgs = @() },
  @{ Name = "medicojob-location-service"; Path = "medicojob-location-service"; BuildArgs = @() },
  @{ Name = "medicojob-reputation-service"; Path = "medicojob-reputation-service"; BuildArgs = @() },
  @{ Name = "medicojob-course-service"; Path = "medicojob-course-service"; BuildArgs = @() },
  @{ Name = "medicojob-resume-service"; Path = "medicojob-resume-service"; BuildArgs = @() },
  @{ Name = "medicojob-frontend"; Path = "medicojob-frontend"; BuildArgs = @("REACT_APP_API_URL=$FrontendApiUrl") }
)

function Assert-Command {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "$Name is required but was not found in PATH."
  }
}

function Invoke-Checked {
  param(
    [string]$FilePath,
    [string[]]$Arguments
  )

  Write-Host "> $FilePath $($Arguments -join ' ')" -ForegroundColor DarkGray
  & $FilePath @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Command failed with exit code $LASTEXITCODE`: $FilePath $($Arguments -join ' ')"
  }
}

Assert-Command "aws"
Assert-Command "docker"

$accountId = (& aws sts get-caller-identity --query Account --output text).Trim()
if (-not $accountId) {
  throw "Could not resolve AWS account ID. Run aws configure or set AWS credentials first."
}

$registry = "$accountId.dkr.ecr.$Region.amazonaws.com"

Push-Location $terraformDir
try {
  $repositoryUrls = @{}
  if (-not $SkipTerraformOutput) {
    try {
      $repositoryUrls = terraform output -json ecr_repository_urls | ConvertFrom-Json -AsHashtable
    } catch {
      Write-Warning "Could not read Terraform ecr_repository_urls output. Falling back to standard ECR URLs."
    }
  }
} finally {
  Pop-Location
}

Write-Host "Logging in to ECR registry $registry..." -ForegroundColor Cyan
$password = (& aws ecr get-login-password --region $Region)
if (-not $password) {
  throw "Could not get ECR login password."
}
$password | docker login --username AWS --password-stdin $registry
if ($LASTEXITCODE -ne 0) {
  throw "Docker login to ECR failed."
}

foreach ($service in $services) {
  $servicePath = Join-Path $repoRoot $service.Path
  $dockerfile = Join-Path $servicePath "Dockerfile"

  if (-not (Test-Path $dockerfile)) {
    throw "Dockerfile not found for $($service.Name): $dockerfile"
  }

  if ($repositoryUrls.ContainsKey($service.Name)) {
    $remoteImage = "$($repositoryUrls[$service.Name]):$Tag"
  } else {
    $remoteImage = "$registry/$($service.Name):$Tag"
  }

  $localImage = "$($service.Name):$Tag"
  $buildArgs = @("build", "-t", $localImage)

  foreach ($arg in $service.BuildArgs) {
    if ($arg -and -not $arg.EndsWith("=")) {
      $buildArgs += @("--build-arg", $arg)
    }
  }

  $buildArgs += @($servicePath)

  Write-Host ""
  Write-Host "Building $($service.Name)..." -ForegroundColor Cyan
  Invoke-Checked "docker" $buildArgs

  Write-Host "Tagging $localImage as $remoteImage..." -ForegroundColor Cyan
  Invoke-Checked "docker" @("tag", $localImage, $remoteImage)

  Write-Host "Pushing $remoteImage..." -ForegroundColor Cyan
  Invoke-Checked "docker" @("push", $remoteImage)
}

Write-Host ""
Write-Host "All MedicoJobs images were pushed to ECR successfully." -ForegroundColor Green
