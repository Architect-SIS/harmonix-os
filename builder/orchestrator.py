"""Build orchestrator — coordinates agent-driven builds."""
class BuildOrchestrator:
    def __init__(self):
        self.agent_url = "http://127.0.0.1:50001"
        self.agui_url = "http://127.0.0.1:3100"
