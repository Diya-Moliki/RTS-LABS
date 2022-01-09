resource aws_cloudwatch_dashboard app {
    dashboard_name = "${var.application_name}-${var.environment}-${var.client_name}"
    dashboard_body = jsonencode(
        {
            widgets = [
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "jvm.threads.states.value",
                                "state",
                                "blocked",
                                "tenant",
                                "${var.client_name}",
                            ],
                            [
                                "...",
                                "new",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "runnable",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "terminated",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "timed-waiting",
                                ".",
                                ".",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Maximum"
                        title   = "threads"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 0
                    y          = 1
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "hikaricp.connections.active.value",
                                "pool",
                                "${var.jdbc_pool_name}",
                                "tenant",
                                "${var.client_name}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Sum"
                        title   = "active connections"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 0
                    y          = 8
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "hikaricp.connections.pending.value",
                                "pool",
                                "${var.jdbc_pool_name}",
                                "tenant",
                                "${var.client_name}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Maximum"
                        title   = "pending connections"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 6
                    y          = 8
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "hikaricp.connections.acquire.max",
                                "pool",
                                "${var.jdbc_pool_name}",
                                "tenant",
                                "${var.client_name}",
                            ],
                            [
                                ".",
                                "hikaricp.connections.acquire.avg",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                ".",
                                "hikaricp.connections.acquire.count",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Sum"
                        title   = "connection acquire"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 12
                    y          = 8
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "hikaricp.connections.usage.sum",
                                "pool",
                                "${var.jdbc_pool_name}",
                                "tenant",
                                "${var.client_name}",
                            ],
                            [
                                ".",
                                "hikaricp.connections.usage.count",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                ".",
                                "hikaricp.connections.usage.avg",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                ".",
                                "hikaricp.connections.usage.max",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Maximum"
                        title   = "connection usage"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 18
                    y          = 8
                },
                {
                    height     = 1
                    properties = {
                        markdown = "# Hikari connection pool"
                    }
                    type       = "text"
                    width      = 24
                    x          = 0
                    y          = 7
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "hibernate.query.executions.count",
                                "entityManagerFactory",
                                "entityManagerFactory",
                                "tenant",
                                "${var.client_name}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Sum"
                        title   = "query executions"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 0
                    y          = 15
                },
                {
                    height     = 1
                    properties = {
                        markdown = "# Hibernate"
                    }
                    type       = "text"
                    width      = 24
                    x          = 0
                    y          = 14
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "hibernate.sessions.open.count",
                                "entityManagerFactory",
                                "entityManagerFactory",
                                "tenant",
                                "${var.client_name}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Sum"
                        title   = "opened sessions"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 6
                    y          = 15
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "hibernate.transactions.count",
                                "result",
                                "failure",
                                "entityManagerFactory",
                                "entityManagerFactory",
                                "tenant",
                                "${var.client_name}",
                            ],
                            [
                                "...",
                                "success",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Sum"
                        title   = "transactions"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 12
                    y          = 15
                },
                {
                    height     = 1
                    properties = {
                        markdown = "# Caches"
                    }
                    type       = "text"
                    width      = 24
                    x          = 0
                    y          = 21
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "cache.size.value",
                                "cache",
                                "OE_ENTITY",
                                "name",
                                "OE_ENTITY",
                                "cacheManager",
                                "cacheManager",
                                "tenant",
                                "${var.client_name}",
                            ],
                            [
                                "...",
                                "PARTICIPANT_ENTITY_LIST",
                                ".",
                                "PARTICIPANT_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "SYSTEM_CONFIG_DTO",
                                ".",
                                "SYSTEM_CONFIG_DTO",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "WORK_LOCATION_ENTITY_LIST",
                                ".",
                                "WORK_LOCATION_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "WORK_ORDER_ENTITY_LIST",
                                ".",
                                "WORK_ORDER_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "FORM_VIEW",
                                ".",
                                "FORM_VIEW",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "FORM_DTO",
                                ".",
                                "FORM_DTO",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "DOCUMENT_VM",
                                ".",
                                "DOCUMENT_VM",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "DOCUMENT_SUMMARY_VM",
                                ".",
                                "DOCUMENT_SUMMARY_VM",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "CLIENT_GROUP_IDS",
                                ".",
                                "CLIENT_GROUP_IDS",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Average"
                        title   = "cache sizes"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 18
                    y          = 22
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "cache.evictions.count",
                                "cache",
                                "WORK_ORDER_ENTITY_LIST",
                                "name",
                                "WORK_ORDER_ENTITY_LIST",
                                "cacheManager",
                                "cacheManager",
                                "tenant",
                                "${var.client_name}",
                            ],
                            [
                                "...",
                                "WORK_LOCATION_ENTITY_LIST",
                                ".",
                                "WORK_LOCATION_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "PARTICIPANT_ENTITY_LIST",
                                ".",
                                "PARTICIPANT_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "CLIENT_GROUP_IDS",
                                ".",
                                "CLIENT_GROUP_IDS",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "DOCUMENT_SUMMARY_VM",
                                ".",
                                "DOCUMENT_SUMMARY_VM",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "DOCUMENT_VM",
                                ".",
                                "DOCUMENT_VM",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "FORM_DTO",
                                ".",
                                "FORM_DTO",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "FORM_VIEW",
                                ".",
                                "FORM_VIEW",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "OE_ENTITY",
                                ".",
                                "OE_ENTITY",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "SYSTEM_CONFIG_DTO",
                                ".",
                                "SYSTEM_CONFIG_DTO",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Maximum"
                        title   = "Cache evictions"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 0
                    y          = 22
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "cache.gets.count",
                                "result",
                                "hit",
                                "cache",
                                "CLIENT_GROUP_IDS",
                                "name",
                                "CLIENT_GROUP_IDS",
                                "cacheManager",
                                "cacheManager",
                                "tenant",
                                "${var.client_name}",
                            ],
                            [
                                "...",
                                "FORM_DTO",
                                ".",
                                "FORM_DTO",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "FORM_VIEW",
                                ".",
                                "FORM_VIEW",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "OE_ENTITY",
                                ".",
                                "OE_ENTITY",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "PARTICIPANT_ENTITY_LIST",
                                ".",
                                "PARTICIPANT_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "SYSTEM_CONFIG_DTO",
                                ".",
                                "SYSTEM_CONFIG_DTO",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "WORK_LOCATION_ENTITY_LIST",
                                ".",
                                "WORK_LOCATION_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "WORK_ORDER_ENTITY_LIST",
                                ".",
                                "WORK_ORDER_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "DOCUMENT_SUMMARY_VM",
                                ".",
                                "DOCUMENT_SUMMARY_VM",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "DOCUMENT_VM",
                                ".",
                                "DOCUMENT_VM",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Average"
                        title   = "cache hits"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 6
                    y          = 22
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "cache.gets.count",
                                "result",
                                "miss",
                                "cache",
                                "CLIENT_GROUP_IDS",
                                "name",
                                "CLIENT_GROUP_IDS",
                                "cacheManager",
                                "cacheManager",
                                "tenant",
                                "${var.client_name}",
                            ],
                            [
                                "...",
                                "FORM_DTO",
                                ".",
                                "FORM_DTO",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "FORM_VIEW",
                                ".",
                                "FORM_VIEW",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "OE_ENTITY",
                                ".",
                                "OE_ENTITY",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "PARTICIPANT_ENTITY_LIST",
                                ".",
                                "PARTICIPANT_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "SYSTEM_CONFIG_DTO",
                                ".",
                                "SYSTEM_CONFIG_DTO",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "WORK_LOCATION_ENTITY_LIST",
                                ".",
                                "WORK_LOCATION_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "WORK_ORDER_ENTITY_LIST",
                                ".",
                                "WORK_ORDER_ENTITY_LIST",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "DOCUMENT_SUMMARY_VM",
                                ".",
                                "DOCUMENT_SUMMARY_VM",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "DOCUMENT_VM",
                                ".",
                                "DOCUMENT_VM",
                                ".",
                                ".",
                                ".",
                                ".",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Average"
                        title   = "cache misses"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 12
                    y          = 22
                },
                {
                    height     = 6
                    properties = {
                        copilot = true
                        legend  = {
                            position = "bottom"
                        }
                        metrics = [
                            [
                                "AWS/RDS",
                                "CPUUtilization",
                                "DBClusterIdentifier",
                                "${var.db_id}",
                                {
                                    id = "m0r1"
                                },
                            ],
                            [
                                "...",
                                "${var.db_id}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Maximum"
                        title   = "CPU Utilization"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 0
                    y          = 29
                },
                {
                    height     = 1
                    properties = {
                        markdown = "# RDS"
                    }
                    type       = "text"
                    width      = 24
                    x          = 0
                    y          = 28
                },
                {
                    height     = 6
                    properties = {
                        copilot = true
                        legend  = {
                            position = "bottom"
                        }
                        metrics = [
                            [
                                "AWS/RDS",
                                "DatabaseConnections",
                                "DBClusterIdentifier",
                                "${var.db_id}",
                                {
                                    id = "m0r1"
                                },
                            ],
                            [
                                "...",
                                "${var.db_id}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Maximum"
                        title   = "Database Connections"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 6
                    y          = 29
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "AWS/RDS",
                                "NetworkThroughput",
                                "DBClusterIdentifier",
                                "${var.db_id}",
                            ],
                            [
                                "...",
                                "${var.db_id}",
                            ],
                        ]
                        period  = 300
                        region  = "${var.region}"
                        stacked = false
                        title   = "NetworkThroughput"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 12
                    y          = 29
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "AWS/RDS",
                                "FreeableMemory",
                                "DBClusterIdentifier",
                                "${var.db_id}",
                            ],
                            [
                                "...",
                                "${var.db_id}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Minimum"
                        title   = "FreeableMemory"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 18
                    y          = 29
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "AWS/ApplicationELB",
                                "TargetResponseTime",
                                "LoadBalancer",
                                "${var.alb_arn_suffix}",
                                {
                                    stat = "Average"
                                },
                            ],
                            [
                                "...",
                                {
                                    stat = "p90"
                                },
                            ],
                            [
                                "...",
                                {
                                    stat = "Maximum"
                                }
                            ]
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Maximum"
                        title   = "TargetResponseTime"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 0
                    y          = 42
                },
                {
                    height     = 1
                    properties = {
                        markdown = "# ALB"
                    }
                    type       = "text"
                    width      = 24
                    x          = 0
                    y          = 41
                },
                {
                    height     = 6
                    properties = {
                        end     = "P0D"
                        metrics = [
                            [
                                "AWS/ApplicationELB",
                                "HTTPCode_ELB_5XX_Count",
                                "LoadBalancer",
                                "${var.alb_arn_suffix}",
                            ],
                            [
                                "AWS/ApplicationELB",
                                "HTTPCode_Target_5XX_Count",
                                "LoadBalancer",
                                "${var.alb_arn_suffix}"
                            ],
                            [ { "expression": "SUM(METRICS())", "label": "HTTP_5XX_Total", "id": "e1" } ]
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        start   = "-PT12H"
                        stat    = "Sum"
                        title   = "HTTPCode_ELB_5XX_Count"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 6
                    y          = 42
                },
                {
                    height     = 6
                    properties = {
                        end     = "P0D"
                        metrics = [
                            [
                                "AWS/ApplicationELB",
                                "RequestCount",
                                "LoadBalancer",
                                "${var.alb_arn_suffix}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        start   = "-PT12H"
                        stat    = "Sum"
                        title   = "RequestCount"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 12
                    y          = 42
                },
                {
                    height     = 6
                    properties = {
                        end     = "P0D"
                        metrics = [
                            [
                                "AWS/ApplicationELB",
                                "ProcessedBytes",
                                "LoadBalancer",
                                "${var.alb_arn_suffix}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        start   = "-PT12H"
                        stat    = "Sum"
                        title   = "ProcessedBytes"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 18
                    y          = 42
                },
                {
                    height     = 1
                    properties = {
                        markdown = "# JVM"
                    }
                    type       = "text"
                    width      = 24
                    x          = 0
                    y          = 0
                },
                {
                    height     = 1
                    properties = {
                        markdown = "# ECS"
                    }
                    type       = "text"
                    width      = 24
                    x          = 0
                    y          = 48
                },
                {
                    height     = 6
                    properties = {
                        legend   = {
                            position = "bottom"
                        }
                        liveData = false
                        metrics  = [
                            [
                                {
                                    expression = "mm1m0 * 100 / mm0m0"
                                    id         = "expr1m0"
                                    label      = "${var.ecs_task_family}"
                                    stat       = "Average"
                                },
                            ],
                            [
                                "ECS/ContainerInsights",
                                "CpuReserved",
                                "ClusterName",
                                "${var.ecs_cluster_name}",
                                "TaskDefinitionFamily",
                                "${var.ecs_task_family}",
                                {
                                    id      = "mm0m0"
                                    stat    = "Sum"
                                    visible = false
                                },
                            ],
                            [
                                ".",
                                "CpuUtilized",
                                ".",
                                ".",
                                ".",
                                ".",
                                {
                                    id      = "mm1m0"
                                    stat    = "Sum"
                                    visible = false
                                },
                            ],
                        ]
                        period   = 60
                        region   = "${var.region}"
                        timezone = "Local"
                        title    = "CPU Utilization"
                        yAxis    = {
                            left = {
                                label     = "Percent"
                                min       = 0
                                showUnits = false
                            }
                        }
                    }
                    type       = "metric"
                    width      = 6
                    x          = 0
                    y          = 49
                },
                {
                    height     = 6
                    properties = {
                        legend   = {
                            position = "bottom"
                        }
                        liveData = false
                        metrics  = [
                            [
                                {
                                    expression = "mm1m0 * 100 / mm0m0"
                                    id         = "expr1m0"
                                    label      = "${var.ecs_task_family}"
                                    stat       = "Average"
                                },
                            ],
                            [
                                "ECS/ContainerInsights",
                                "MemoryReserved",
                                "ClusterName",
                                "${var.ecs_cluster_name}",
                                "TaskDefinitionFamily",
                                "${var.ecs_task_family}",
                                {
                                    id      = "mm0m0"
                                    stat    = "Sum"
                                    visible = false
                                },
                            ],
                            [
                                ".",
                                "MemoryUtilized",
                                ".",
                                ".",
                                ".",
                                ".",
                                {
                                    id      = "mm1m0"
                                    stat    = "Sum"
                                    visible = false
                                },
                            ],
                        ]
                        period   = 60
                        region   = "${var.region}"
                        timezone = "Local"
                        title    = "Memory Utilization"
                        yAxis    = {
                            left = {
                                label     = "Percent"
                                min       = 0
                                showUnits = false
                            }
                        }
                    }
                    type       = "metric"
                    width      = 6
                    x          = 6
                    y          = 49
                },
                {
                    height     = 6
                    properties = {
                        legend   = {
                            position = "bottom"
                        }
                        liveData = false
                        metrics  = [
                            [
                                {
                                    expression = "mm0m0"
                                    id         = "expr1m0"
                                    label      = "${var.ecs_task_family}"
                                    region     = "${var.region}"
                                    stat       = "Average"
                                },
                            ],
                            [
                                "ECS/ContainerInsights",
                                "NetworkTxBytes",
                                "ClusterName",
                                "${var.ecs_cluster_name}",
                                "TaskDefinitionFamily",
                                "${var.ecs_task_family}",
                                {
                                    id      = "mm0m0"
                                    stat    = "Sum"
                                    visible = false
                                },
                            ],
                        ]
                        period   = 60
                        region   = "${var.region}"
                        stacked  = false
                        timezone = "Local"
                        title    = "Network TX"
                        view     = "timeSeries"
                        yAxis    = {
                            left = {
                                label     = "Bytes/Second"
                                showUnits = false
                            }
                        }
                    }
                    type       = "metric"
                    width      = 6
                    x          = 12
                    y          = 49
                },
                {
                    height     = 6
                    properties = {
                        legend   = {
                            position = "bottom"
                        }
                        liveData = false
                        metrics  = [
                            [
                                {
                                    expression = "mm0m0"
                                    id         = "expr1m0"
                                    label      = "${var.ecs_task_family}"
                                    region     = "${var.region}"
                                    stat       = "Average"
                                },
                            ],
                            [
                                "ECS/ContainerInsights",
                                "NetworkRxBytes",
                                "ClusterName",
                                "${var.ecs_cluster_name}",
                                "TaskDefinitionFamily",
                                "${var.ecs_task_family}",
                                {
                                    id      = "mm0m0"
                                    stat    = "Sum"
                                    visible = false
                                },
                            ],
                        ]
                        period   = 60
                        region   = "${var.region}"
                        stacked  = false
                        timezone = "Local"
                        title    = "Network RX"
                        view     = "timeSeries"
                        yAxis    = {
                            left = {
                                label     = "Bytes/Second"
                                showUnits = false
                            }
                        }
                    }
                    type       = "metric"
                    width      = 6
                    x          = 18
                    y          = 49
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "${var.application_name}-${var.environment}",
                                "jvm.memory.used.value",
                                "area",
                                "heap",
                                "id",
                                "Eden Space",
                                "tenant",
                                "${var.client_name}",
                            ],
                            [
                                "...",
                                "Survivor Space",
                                ".",
                                ".",
                            ],
                            [
                                "...",
                                "Tenured Gen",
                                ".",
                                ".",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Maximum"
                        title   = "Heap used"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 6
                    y          = 1
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "AWS/ApplicationELB",
                                "HealthyHostCount",
                                "TargetGroup",
                                "${var.tg_arn_suffix}",
                                "LoadBalancer",
                                "${var.alb_arn_suffix}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Average"
                        title   = "healthy Hosts"
                        view    = "timeSeries"
                        yAxis   = {
                            left = {
                                min = 0
                            }
                        }
                    }
                    type       = "metric"
                    width      = 6
                    x          = 6
                    y          = 55
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "AWS/RDS",
                                "FreeLocalStorage",
                                "DBClusterIdentifier",
                                "${var.db_id}",
                            ],
                            [
                                "...",
                                "${var.db_id}",
                            ],
                        ]
                        period  = 300
                        region  = "${var.region}"
                        stacked = false
                        title   = "FreeLocalStorage"
                        view    = "timeSeries"
                    }
                    type       = "metric"
                    width      = 6
                    x          = 0
                    y          = 35
                },
                {
                    height     = 6
                    properties = {
                        metrics = [
                            [
                                "AWS/ApplicationELB",
                                "UnHealthyHostCount",
                                "TargetGroup",
                                "${var.tg_arn_suffix}",
                                "LoadBalancer",
                                "${var.alb_arn_suffix}",
                            ],
                        ]
                        period  = 60
                        region  = "${var.region}"
                        stacked = false
                        stat    = "Maximum"
                        title   = "Unhealthy Hosts"
                        view    = "timeSeries"
                        yAxis   = {
                            left = {
                                min = 0
                            }
                        }
                    }
                    type       = "metric"
                    width      = 6
                    x          = 0
                    y          = 55
                },
            ]
        }
    )
}
