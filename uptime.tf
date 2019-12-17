/**
 * Copyright 2019 Taito United
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

data "azurerm_application_insights" "zone" {
  name                    = var.resource_group
  resource_group_name     = data.azurerm_resource_group.namespace.name
}

resource "azurerm_application_insights_web_test" "uptimez" {
  count                   = length(var.uptime_targets)

  name                    = "${var.project}-${var.env}-${var.uptime_targets[count.index]}"
  location                = data.azurerm_resource_group.namespace.location
  resource_group_name     = data.azurerm_resource_group.namespace.name
  application_insights_id = data.azurerm_application_insights.zone.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = var.uptime_timeouts[count.index]
  enabled                 = true
  geo_locations           = ["us-ca-sjc-azr", "emea-nl-ams-azr", "emea-gb-db3-azr"]

  tags = {
    namespace = var.resource_group
    name = "${var.project}-${var.env}"
    domain = var.domain
    target = var.uptime_targets[count.index]
    path = var.uptime_paths[count.index]
  }

  configuration = <<XML
<WebTest Name="WebTest1" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="https://${var.domain}${var.uptime_paths[count.index]}" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML
}
